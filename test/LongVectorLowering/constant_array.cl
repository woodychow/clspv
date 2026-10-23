// RUN: clspv %target %s --long-vector -o %t.spv
// RUN: spirv-dis -o %t.spvasm %t.spv
// RUN: FileCheck %s < %t.spvasm
// RUN: spirv-val --target-env vulkan1.0 %t.spv
//
// RUN: clspv %target %s --long-vector --module-constants-in-storage-buffer -o %t2.spv
// RUN: spirv-dis -o %t2.spvasm %t2.spv
// RUN: FileCheck %s < %t2.spvasm --check-prefix=CLUSTERED
// RUN: spirv-val --target-env vulkan1.0 %t2.spv

__constant int8 lut[2] = {
    (int8)(0, 1, 2, 3, 4, 5, 6, 7),
    (int8)(8, 9, 10, 11, 12, 13, 14, 15),
};

__constant int8 lut2d[2][2] = {
    {
        (int8)(0, 1, 2, 3, 4, 5, 6, 7),
        (int8)(8, 9, 10, 11, 12, 13, 14, 15),
    },
    {
        (int8)(16, 17, 18, 19, 20, 21, 22, 23),
        (int8)(0),
    },
};

__kernel void test(__global int8 *out, int i, int j) {
  const int8 local_lut[2] = {
      (int8)(100, 101, 102, 103, 104, 105, 106, 107),
      (int8)(200, 201, 202, 203, 204, 205, 206, 207),
  };
  out[0] = lut[i] + lut[1] + lut2d[i][j] + local_lut[i];
}

// CHECK-NOT: OpTypeVector {{%[a-zA-Z0-9_]+}} 8
// CHECK-DAG: [[uint:%[a-zA-Z0-9_]+]] = OpTypeInt 32 0
// CHECK-DAG: [[uint_2:%[a-zA-Z0-9_]+]] = OpConstant [[uint]] 2
// CHECK-DAG: [[uint_8:%[a-zA-Z0-9_]+]] = OpConstant [[uint]] 8
// CHECK-DAG: [[arr8:%[a-zA-Z0-9_]+]] = OpTypeArray [[uint]] [[uint_8]]
// CHECK-DAG: [[arr2x8:%[a-zA-Z0-9_]+]] = OpTypeArray [[arr8]] [[uint_2]]
// CHECK-DAG: [[arr2x2x8:%[a-zA-Z0-9_]+]] = OpTypeArray [[arr2x8]] [[uint_2]]

// CLUSTERED-NOT: OpTypeVector {{%[a-zA-Z0-9_]+}} 8
// CLUSTERED-DAG: [[uint:%[a-zA-Z0-9_]+]] = OpTypeInt 32 0
// CLUSTERED-DAG: [[uint_2:%[a-zA-Z0-9_]+]] = OpConstant [[uint]] 2
// CLUSTERED-DAG: [[uint_8:%[a-zA-Z0-9_]+]] = OpConstant [[uint]] 8
// CLUSTERED-DAG: [[arr8:%[a-zA-Z0-9_]+]] = OpTypeArray [[uint]] [[uint_8]]
// CLUSTERED-DAG: [[arr2x8:%[a-zA-Z0-9_]+]] = OpTypeArray [[arr8]] [[uint_2]]
// CLUSTERED-DAG: [[arr2x2x8:%[a-zA-Z0-9_]+]] = OpTypeArray [[arr2x8]] [[uint_2]]
