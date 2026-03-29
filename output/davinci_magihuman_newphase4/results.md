# daVinci-MagiHuman New Phase4 Results

- status: success
- run_id: full_body_3_fusion_prompt_approx_768x768_251f
- requested_output_reference: /root/autodl-tmp/fusion_forcing/test_outputs/ltx23_distilled_compare_20260322_053332/distilled_compare_768x768_249f.mp4
- actual_video: /root/autodl-tmp/avatar-benchmark/output/davinci_magihuman_newphase4/full_body_3_fusion_prompt_approx_768x768_251f_10s_384x384.mp4
- config_record: /root/autodl-tmp/avatar-benchmark/output/davinci_magihuman_newphase4/config_full_body_3_fusion_prompt_approx_768x768_251f.json
- runtime_config: /root/autodl-tmp/avatar-benchmark/output/davinci_magihuman_newphase4/runtime_full_body_3_fusion_prompt_approx_768x768_251f.json
- log: /root/autodl-tmp/avatar-benchmark/output/davinci_magihuman_newphase4/logs/full_body_3_fusion_prompt_approx_768x768_251f.log
- script: /root/autodl-tmp/avatar-benchmark/test/davinci_magihuman/run_custom_fullbody3_fusion_prompt.sh
- runtime_seconds: 264
- gpu_peak_mb: 49487
- actual_resolution: 768x768
- actual_fps: 25.0
- actual_frames: 249
- internal_audio_latent_frames: 251
- note: 当前 CLI 仍按 `--seconds 10` 生成内部 251-step 时序，但最终编码 mp4 的探针结果为 `249` 帧，已与目标 `249f` 对齐。
