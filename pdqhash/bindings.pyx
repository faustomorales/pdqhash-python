# distutils: language = c++
# cython: language_level=3
# cython: language=c++

import numpy as np
cimport numpy as np

cdef extern from "patches.h":
    pass

cdef extern from "pdq/cpp/common/pdqhashtypes.cpp" namespace "facebook::pdq::hashing":
    cdef struct Hash256:
        unsigned short w[16]
        

cdef extern from "pdq/cpp/hashing/pdqhashing.cpp" namespace "facebook::pdq::hashing":
    void pdqHash256FromFloatLuma(
        float* fullBuffer1,
        float* fullBuffer2,
        int numRows,
        int numCols,
        float buffer64x64[64][64],
        float buffer16x64[16][64],
        float buffer16x16[16][16],
        Hash256& hash_value,
        int& quality
    )

cdef extern from "pdq/cpp/hashing/pdqhashing.cpp" namespace "facebook::pdq::hashing":
    void pdqFloat256FromFloatLuma(
        float* fullBuffer1,
        float* fullBuffer2,
        int numRows,
        int numCols,
        float buffer64x64[64][64],
        float buffer16x64[16][64],
        float output_buffer16x16[16][16],
        int& quality
    )

cdef extern from "pdq/cpp/hashing/pdqhashing.cpp" namespace "facebook::pdq::hashing":
    void pdqDihedralHash256esFromFloatLuma(
        float* fullBuffer1,
        float* fullBuffer2,
        int numRows,
        int numCols,
        float buffer64x64[64][64],
        float buffer16x64[16][64],
        float buffer16x16[16][16],
        float buffer16x16Aux[16][16],
        Hash256* hashptrOriginal,
        Hash256* hashptrRotate90,
        Hash256* hashptrRotate180,
        Hash256* hashptrRotate270,
        Hash256* hashptrFlipX,
        Hash256* hashptrFlipY,
        Hash256* hashptrFlipPlus1,
        Hash256* hashptrFlipMinus1,
        int& quality
    )

cdef extern from "pdq/cpp/downscaling/downscaling.cpp" namespace "facebook::pdq::downscaling":
    int computeJaroszFilterWindowSize(int oldDimension, int newDimension)

cdef extern from "pdq/cpp/hashing/torben.cpp" namespace "facebook::pdq::hashing":
    float torben(float m[], int n)

def hash_to_vector(hash_value):
    return np.array([(hash_value[(k & 255) >> 4] >> (k & 15)) & 1 for k in range(256)])[::-1]

def compute(np.ndarray[char, ndim=3] image):
    cdef np.ndarray[float, ndim=2] gray = (image[:, :, 0]*0.299 + image[:, :, 1]*0.587 + image[:, :, 2] * 0.114).astype('float32')
    cdef np.ndarray[float, ndim=2] placeholder = np.zeros_like(gray)
    cdef Hash256 hash_value = Hash256()
    cdef int quality
    cdef int numRows = gray.shape[0]
    cdef int numCols = gray.shape[1]
    cdef float buffer64x64[64][64]
    cdef float buffer16x64[16][64]
    cdef float buffer16x16[16][16]
    cdef float* fullBuffer1 = &gray[0, 0]
    cdef float* fullBuffer2 = &placeholder[0, 0]
    result = pdqHash256FromFloatLuma(
        fullBuffer1,
        fullBuffer2,
        numRows,
        numCols,
        buffer64x64,
        buffer16x64,
        buffer16x16,
        hash_value,
        quality
    )
    
    return hash_to_vector(hash_value.w), quality

def compute_float(np.ndarray[char, ndim=3] image):
    cdef np.ndarray[float, ndim=2] gray = (image[:, :, 0]*0.299 + image[:, :, 1]*0.587 + image[:, :, 2] * 0.114).astype('float32')
    cdef np.ndarray[float, ndim=2] placeholder = np.zeros_like(gray)
    cdef int quality
    cdef int numRows = gray.shape[0]
    cdef int numCols = gray.shape[1]
    cdef float buffer64x64[64][64]
    cdef float buffer16x64[16][64]
    cdef float buffer16x16[16][16]
    cdef float* fullBuffer1 = &gray[0, 0]
    cdef float* fullBuffer2 = &placeholder[0, 0]
    pdqFloat256FromFloatLuma(
        fullBuffer1,
        fullBuffer2,
        numRows,
        numCols,
        buffer64x64,
        buffer16x64,
        buffer16x16,
        quality)    
    return np.array(buffer16x16).flatten()[::-1], quality

def compute_dihedral(np.ndarray[char, ndim=3] image):
    cdef np.ndarray[float, ndim=2] gray = (image[:, :, 0]*0.299 + image[:, :, 1]*0.587 + image[:, :, 2] * 0.114).astype('float32')
    cdef np.ndarray[float, ndim=2] placeholder = np.zeros_like(gray)
    cdef Hash256 hashptrOriginal = Hash256()
    cdef Hash256 hashptrRotate90 = Hash256()
    cdef Hash256 hashptrRotate180 = Hash256()
    cdef Hash256 hashptrRotate270 = Hash256()
    cdef Hash256 hashptrFlipX = Hash256()
    cdef Hash256 hashptrFlipY = Hash256()
    cdef Hash256 hashptrFlipPlus1 = Hash256()
    cdef Hash256 hashptrFlipMinus1 = Hash256()
    cdef int quality
    cdef int numRows = gray.shape[0]
    cdef int numCols = gray.shape[1]
    cdef float buffer64x64[64][64]
    cdef float buffer16x64[16][64]
    cdef float buffer16x16[16][16]
    cdef float buffer16x16Aux[16][16]
    cdef float* fullBuffer1 = &gray[0, 0]
    cdef float* fullBuffer2 = &placeholder[0, 0]
    result = pdqDihedralHash256esFromFloatLuma(
            fullBuffer1,
            fullBuffer2,
            numRows,
            numCols,
            buffer64x64,
            buffer16x64,
            buffer16x16,
            buffer16x16Aux,
            &hashptrOriginal,
            &hashptrRotate90,
            &hashptrRotate180,
            &hashptrRotate270,
            &hashptrFlipX,
            &hashptrFlipY,
            &hashptrFlipPlus1,
            &hashptrFlipMinus1,
            quality
        )
    return [
        hash_to_vector(hashptrOriginal.w),
        hash_to_vector(hashptrRotate90.w),
        hash_to_vector(hashptrRotate180.w),
        hash_to_vector(hashptrRotate270.w),
        hash_to_vector(hashptrFlipX.w),
        hash_to_vector(hashptrFlipY.w),
        hash_to_vector(hashptrFlipPlus1.w),
        hash_to_vector(hashptrFlipMinus1.w)
    ], quality
