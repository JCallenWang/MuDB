import torchaudio
import time
import os
import json
from audiocraft.models import MusicGen
from audiocraft.data.audio import audio_write

generate_count = 70
start_index = 20
output_dir = './test6_fixed1_temp'
audio_duration = 30

curr_tk = 250    # start with 32 (32~1000)
curr_tp = 0   # start with 0.9 (0.9~10)
curr_temp = 3.0 # Prior, start with 1.0 (1~10), when tk=32, tp=0.9, temp.max(1.0)
curr_cfg = 3.0  # start with 2.0 (2~10)
curr_2cfg = False
curr_extend = 3.0 # set 0 will fail, set to 1&2&3 is useless when duration(60s)

print(f"checking output directory in {os.path.abspath(output_dir)}...")
os.makedirs(output_dir, exist_ok=True)

model = MusicGen.get_pretrained('facebook/musicgen-medium')
for i in range(generate_count):
    start_time = time.time()

    model.set_generation_params(top_k=curr_tk, top_p=curr_tp, temperature=curr_temp, cfg_coef=curr_cfg, duration=audio_duration, two_step_cfg=curr_2cfg, extend_stride=curr_extend)
    descriptions = ['create a jazz, jazz instrument, blues, blues/jazz, relaxing, mellow, downtempo, calm music with only piano and cello, perfect for a commercial']
    wav = model.generate(descriptions)
    
    for idx, one_wav in enumerate(wav):
        output_filename = f'{os.path.abspath(output_dir)}\{start_index + i}'
        audio_write(
            output_filename,
            one_wav.cpu(),
            model.sample_rate,
            strategy="loudness",
            loudness_compressor=True
        )

        end_time = time.time()
        generation_time = end_time - start_time
        # wrirting generate informations
        metadata = {
            "Top-k": curr_tk,
            "Top-p": curr_tp,
            "Temperature": curr_temp,
            "Classifier Free Guidance": curr_cfg,
            "2 Steps Classifier Free Guidance": curr_2cfg,
            "Extend Stride": curr_extend,
            "Generated Time": f'{generation_time:.2f}',
            "Audio duration": audio_duration,
            "audio file": f'{output_filename}.wav'
        }
        output_json_path = f'{output_dir}/metadata.json'
        if(os.path.exists(output_json_path)):
            with open(output_json_path, 'r') as f:
                metadata_list = json.load(f)
        else:
            metadata_list = []

        metadata_list.append(metadata)
        with open(output_json_path, 'w') as f:
            json.dump(metadata_list, f, indent=4)

        print(f"[OK] generate of {output_filename}.wav complete, metadata save to {os.path.abspath(output_json_path)}...")

    #curr_tk += 1
    #curr_tp += 0.1
    curr_temp += 0.1
    #curr_cfg += 0.1
    curr_temp = round(curr_temp, 1)

