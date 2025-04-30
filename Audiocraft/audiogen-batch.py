import torchaudio
import time
import os
import json
from audiocraft.models import MusicGen
from audiocraft.data.audio import audio_write

generate_count = 91
start_index = 0
dir_output = './test8'
audio_duration = 30
curr_2cfg = False
curr_extend = 3.0 # set 0 will fail, set to 1&2&3 is useless when duration(60s)

print(f"checking output directory in {os.path.abspath(dir_output)}...")
os.makedirs(dir_output, exist_ok=True)
model = MusicGen.get_pretrained('facebook/musicgen-medium')

def generate_multiple_audio_with_elavated_prams(output_dir, index, tk_start, tk_max, tp_start, tp_max, temp_start, temp_max, cfg, cfg_2, extend, length):
    while(tk_start < tk_max):
        tp_start = 0.0
        while(tp_start <= tp_max):
            temp_start = 0.0
            while(temp_start <= temp_max):
                start_time = time.time()
                model.set_generation_params(top_k=tk_start, top_p=tp_start, temperature=temp_start, cfg_coef=cfg, duration=length, two_step_cfg=cfg_2, extend_stride=extend)
                descriptions = ['create a jazz, jazz instrument, blues, blues/jazz, relaxing, mellow, downtempo, calm music with only piano and cello, perfect for a commercial']
                wav = model.generate(descriptions)

                for i, one_wav in enumerate(wav):
                    output_filename = f'{os.path.abspath(output_dir)}\{index}'
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
                        "Top-k": tk_start,
                        "Top-p": tp_start,
                        "Temperature": temp_start,
                        "Classifier Free Guidance": cfg,
                        "2 Steps Classifier Free Guidance": cfg_2,
                        "Extend Stride": extend,
                        "Generated Time": f'{generation_time:.2f}',
                        "Audio duration": length,
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
                    index += 1

                temp_start += 0.1
                temp_start = round(temp_start, 1)
            tp_start += 0.1
            tp_start = round(tp_start, 1)
        tk_start += 1

def generate_single_audio(output_dir, index, k, p, temp, cfg, cfg_2, extend, length):
    start_time = time.time()
    model.set_generation_params(top_k=k, top_p=p, temperature=temp, cfg_coef=cfg, two_step_cfg=cfg_2, extend_stride=extend, duration=length)
    descriptions = ['create a jazz, jazz instrument, blues, blues/jazz, relaxing, mellow, downtempo, calm music with only piano and cello, perfect for a commercial']
    wav = model.generate(descriptions)
    for i, one_wav in enumerate(wav):
        output_filename = f'{os.path.abspath(output_dir)}\{index}'
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
            "Top-k": k,
            "Top-p": p,
            "Temperature": temp,
            "Classifier Free Guidance": cfg,
            "2 Steps Classifier Free Guidance": cfg_2,
            "Extend Stride": extend,
            "Generated Time": f'{generation_time:.2f}',
            "Audio duration": length,
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

generate_multiple_audio_with_elavated_prams(dir_output, 1271, 43, 500, 0.5, 1.0, 0.6, 1.0, 2.0, curr_2cfg, curr_extend, audio_duration)

#for i in range(50):
#    generate_single_audio(dir_output, i, 50, 0.9, 0.9, 3.5, curr_2cfg, curr_extend, audio_duration)