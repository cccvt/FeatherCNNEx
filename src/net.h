//Tencent is pleased to support the open source community by making FeatherCNN available.

//Copyright (C) 2018 THL A29 Limited, a Tencent company. All rights reserved.

//Licensed under the BSD 3-Clause License (the "License"); you may not use this file except
//in compliance with the License. You may obtain a copy of the License at
//
//https://opensource.org/licenses/BSD-3-Clause
//
//Unless required by applicable law or agreed to in writing, software distributed
//under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
//CONDITIONS OF ANY KIND, either express or implied. See the License for the
//specific language governing permissions and limitations under the License.

#pragma once

#include "layer.h"
#include "rt_param.h"
#include <vector>
#include <map>
#include <common.h>

namespace feather
{
class Layer;

class Net
{
public:
    Net(size_t num_threads);
    ~Net();

    void InitFromPath(const char *model_path);
    void InitFromFile(FILE *fp);
    bool InitFromBuffer(const void *net_buffer);
    int  Forward(float* input);
    int GetBlobDataSize(size_t* data_size, std::string blob_name);
    int ExtractBlob(float* output_ptr, std::string blob_name);//Don't forget to free this memory.
    std::map<std::string, Layer*> layer_map;
#define MAXBRANCHNUM 16
    float *pingpang[MAXBRANCHNUM][2];
    unsigned branchPingPang[MAXBRANCHNUM];
    unsigned branchCnt;
    unsigned max_top_blob_size;
private:
    void branchBufferInit(unsigned branchId);
    std::vector<Layer *> layers;
    RuntimeParameter<float> *rt_param;
    std::map<std::string, const Blob<float> *> blob_map;
};
};
