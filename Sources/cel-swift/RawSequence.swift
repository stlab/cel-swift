public struct RawSequence {
    private static let blockLimit = 4096  // roughly 4KB blocks
    private var buffer: [[UInt8]] = [[]]
    private var currentBlock = 0

    /// Creates a new `RawSequence` instance.
    public init() {
        buffer[currentBlock].reserveCapacity(RawSequence.blockLimit)
    }

    /// Pushes a value of type `T` onto the stack.
    ///
    /// - Parameter value: The value to push onto the stack
    public mutating func push<T>(_ value: T) {
        if (buffer[currentBlock].count + MemoryLayout<T>.maximumSize) > RawSequence.blockLimit {
            currentBlock += 1
            if currentBlock == buffer.count {
                buffer.append([])
                buffer[currentBlock].reserveCapacity(RawSequence.blockLimit)
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
        buffer[currentBlock].removeLast(buffer[currentBlock].count - offset)
    }

    /*
    Retrieves a reference to the next value at the specified position.

    # Safety
    - The position must point to a valid value of type T
    - The caller must ensure that the value is actually of type T
    - The caller must ensure that the position is within the bounds of the buffer

    Returns a tuple containing:
    - A reference to the value
    - The position immediately after the value
    */
    public func unsafeNext<T>(at position: Int) -> (value: T, nextPosition: Int)? {
        let size = MemoryLayout<T>.size
        let alignment = MemoryLayout<T>.alignment

        var blockIndex = 0
        var currentOffset = position
        var found = false

        for block in buffer {
            if currentOffset < block.count {
                found = true
                break
            } else {
                currentOffset -= block.count
                blockIndex += 1
            }
        }

        guard found, blockIndex < buffer.count else {
            return nil
        }

        let alignedPosition = align(offset: currentOffset, to: alignment)

        guard alignedPosition + size <= buffer[blockIndex].count else {
            return nil
        }

        let ptr = buffer[blockIndex].withUnsafeBytes { bufferPtr in
            return bufferPtr.baseAddress!.advanced(by: alignedPosition).assumingMemoryBound(
                to: T.self)
        }

        return (ptr.pointee, position + size)
    }

    private func align(offset: Int, to alignment: Int) -> Int {
        return (offset + alignment - 1) & ~(alignment - 1)
    }
}
