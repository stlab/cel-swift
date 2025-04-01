/// Returns a properly aligned pointer for type T given an unaligned pointer.
///
/// - Parameters:
///   - p: The unaligned pointer
///   - type: The type to align for
/// - Returns: A pointer aligned for type T
/// - Precondition: p + required alignment offset is a valid pointer
private func unsafeAligned<T>(_ p: UnsafeMutablePointer<UInt8>, for type: T.Type = T.self)
    -> UnsafeMutablePointer<UInt8>
{
    let alignment = MemoryLayout<T>.alignment
    let offset = alignment - Int(UInt(bitPattern: p) % UInt(alignment))
    return p + (offset == alignment ? 0 : offset)
}

extension MemoryLayout {
    /// Returns the maximum size needed to allocate a properly aligned value of type T.
    ///
    /// This includes the size of T plus any padding needed for alignment.
    ///
    /// - Returns: Maximum number of bytes needed for an aligned value of type T
    static var maximumSize: Int {
        size + alignment - 1
    }
}

/// A simple raw stack that stores values as raw bytes.
///
/// `RawStack` allows pushing values of any type into a byte buffer and retrieving
/// them manually. The retrieval (`pop`) operation is unsafe and requires the caller
/// to ensure that the type parameter matches the value at the top of the stack.
public struct RawStack {
    private static let blockLimit = 4096  // roughly 4KB blocks
    private var buffer: [[UInt8]] = [[]]
    private var currentBlock = 0

    /// Creates a new `RawStack` with an initial capacity.
    ///
    /// - Returns: A new empty `RawStack`
    public init() {
        buffer[currentBlock].reserveCapacity(RawStack.blockLimit)
    }

    /// Pushes a value of type `T` onto the stack.
    ///
    /// The value is stored as raw bytes in the internal buffer. The pushed value must be
    /// later popped using the correct type.
    ///
    /// - Parameter value: The value to push onto the stack (consumed)
    /// - Complexity: O(1) amortized
    public mutating func push<T>(consuming value: T) {
        // Grow the buffer to hold an aligned value of type T
        if (buffer[currentBlock].count + MemoryLayout<T>.maximumSize) > RawStack.blockLimit {
            currentBlock += 1
            if currentBlock == buffer.count {
                buffer.append([])
                buffer[currentBlock].reserveCapacity(RawStack.blockLimit)
            }
        }
        let initialLength = buffer[currentBlock].count
        buffer[currentBlock].append(
            contentsOf: repeatElement(0, count: MemoryLayout<T>.maximumSize))
        let offset = buffer[currentBlock].withUnsafeMutableBufferPointer { ptr in
            let alignedPtr = unsafeAligned(ptr.baseAddress! + initialLength, for: T.self)
            UnsafeMutableRawPointer(alignedPtr).initializeMemory(
                as: T.self,
                to: value)
            return alignedPtr - ptr.baseAddress!
        }
        buffer[currentBlock].removeSubrange(initialLength..<offset)
        buffer[currentBlock].removeLast(MemoryLayout<T>.alignment - 1)
    }

    /// Pops a value of type `T` from the stack.
    ///
    /// - Warning: This is an unsafe operation. The type `T` must match the type of the value
    ///   at the top of the stack. Incorrect usage can lead to undefined behavior.
    ///
    /// - Returns: The value popped from the stack
    public mutating func unsafePop<T>() -> T {
        // We need to ensure that value T at the top of the stack is properly aligned
        // First grow the buffer so T can be aligned within it.
        if buffer[currentBlock].isEmpty {
            currentBlock -= 1
        }

        let initialLength = buffer[currentBlock].count
        buffer[currentBlock].append(
            contentsOf: repeatElement(0, count: MemoryLayout<T>.alignment - 1))
        let result = buffer[currentBlock].withUnsafeMutableBufferPointer { ptr in
            let alignedPtr = unsafeAligned(
                ptr.baseAddress! + initialLength - MemoryLayout<T>.size, for: T.self)
            let size = MemoryLayout<T>.size
            UnsafeMutableRawPointer(alignedPtr).copyMemory(
                from: ptr.baseAddress! + initialLength - size, byteCount: size)
            return UnsafeMutableRawPointer(alignedPtr).assumingMemoryBound(to: T.self).move()
        }
        buffer[currentBlock].removeLast(MemoryLayout<T>.maximumSize)
        return result
    }

    /// Pops a value of type `T` from the stack and drops it.
    ///
    /// - Warning: This is an unsafe operation. The type `T` must match the type of the value
    ///   at the top of the stack. Incorrect usage can lead to undefined behavior.
    public mutating func unsafeDrop<T>(_ type: T.Type) {
        _ = unsafePop() as T
    }
}

#if DEBUG
    extension RawStack {
        /// Returns the current size of the stack in bytes
        public var empty: Bool { currentBlock == 0 && buffer[currentBlock].isEmpty }

        /// Returns the raw buffer contents (for debugging)
        public var debugDescription: String {
            "RawStack(buffer: \(buffer))"
        }
    }
#endif
