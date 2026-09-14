from settings import OUTPUT_WIDTH, OUTPUT_HEIGHT, DEFAULT_CRF

def build_ffmpeg_command(
    ffmpeg_path,
    input_path,
    output_path,
    blur,
    darkness,
    mode,
    enable_frame,
    frame_color,
    frame_width,
    overlay_path,
    enable_overlay_recolor,
    overlay_color,
    is_preview=False,
    animated_bg_path="",
    animated_bg_is_long=False,
    animated_bg_is_loop=False,
    codec_format="MP4 • H.264",
):
    if mode == "Zoom":
        background = (
            f"[bg]"
            f"crop=iw:iw*9/16,"
            f"scale={OUTPUT_WIDTH}:{OUTPUT_HEIGHT},"
            f"gblur=sigma={blur},"
            f"eq=brightness={darkness}"
            f"[blurred]"
        )
    else:
        background = (
            f"[bg]"
            f"scale={OUTPUT_WIDTH}:{OUTPUT_HEIGHT},"
            f"gblur=sigma={blur},"
            f"eq=brightness={darkness}"
            f"[blurred]"
        )

    cmd = [
        str(ffmpeg_path),
        "-y",
        "-i",
        input_path,
    ]

    input_idx = 1
    overlay_idx = -1
    animated_bg_idx = -1

    if overlay_path:
        cmd.extend([
            "-i",
            overlay_path,
        ])
        overlay_idx = input_idx
        input_idx += 1
        
    if animated_bg_path:
        if not animated_bg_is_long and animated_bg_is_loop:
            cmd.extend(["-stream_loop", "-1"])
        cmd.extend([
            "-i",
            animated_bg_path
        ])
        animated_bg_idx = input_idx
        input_idx += 1

    if enable_frame:
        ffmpeg_color = frame_color.replace("#", "0x")
        fw2 = frame_width * 2
        foreground = (
            f"[orig]"
            f"scale=-2:{OUTPUT_HEIGHT - fw2},"
            f"pad=iw+{fw2}:ih+{fw2}:{frame_width}:{frame_width}:{ffmpeg_color}"
            f"[foreground]"
        )
    else:
        foreground = (
            f"[orig]"
            f"scale=-2:{OUTPUT_HEIGHT}"
            f"[foreground]"
        )

    filters = [
        "split[orig][bg]",
        background,
        foreground,
    ]

    comp_out = "[comp1]" if (overlay_path or animated_bg_path) else ""
    if enable_frame:
        filters.append(
            "[blurred]"
            "[foreground]"
            f"overlay=(W-w)/2:(H-h)/2{comp_out}"
        )
    else:
        filters.append(
            "[blurred]"
            "[foreground]"
            f"overlay=(W-w)/2:0{comp_out}"
        )

    current_comp = "[comp1]"
    next_comp_idx = 2

    if animated_bg_path:
        next_comp = f"[comp{next_comp_idx}]" if overlay_path else ""
        filters.append(f"{current_comp}[{animated_bg_idx}:v]overlay=shortest=1{next_comp}")
        current_comp = next_comp
        next_comp_idx += 1

    if overlay_path:
        if enable_overlay_recolor:
            ffmpeg_recolor = overlay_color.replace("#", "0x")
            filters.append(f"color=c={ffmpeg_recolor}:s={OUTPUT_WIDTH}x{OUTPUT_HEIGHT}:d=1[color_bg]")
            filters.append(f"[{overlay_idx}:v]alphaextract[alpha]")
            filters.append(f"[color_bg][alpha]alphamerge[colored_overlay]")
            filters.append(f"{current_comp}[colored_overlay]overlay=0:0")
        else:
            filters.append(f"{current_comp}[{overlay_idx}:v]overlay=0:0")

    filter_complex_str = ";".join(filters)

    cmd.extend([
        "-filter_complex",
        filter_complex_str,
    ])

    if is_preview:
        cmd.extend([
            "-vframes", "1",
            "-q:v", "2",
            output_path
        ])
    else:
        if codec_format in ["MP4 • H.264", "MOV • H.264"]:
            cmd.extend([
                "-c:v", "libx264",
                "-crf", str(DEFAULT_CRF),
                "-pix_fmt", "yuv420p",
                "-c:a", "aac"
            ])
        elif codec_format == "MOV • ProRes 422":
            cmd.extend([
                "-c:v", "prores_ks",
                "-profile:v", "2",
                "-pix_fmt", "yuv422p10le",
                "-c:a", "pcm_s16le",
                "-ar", "48000"
            ])
        elif codec_format in ["AVI • AVC-Intra 100", "MXF • AVC-Intra 100"]:
            cmd.extend([
                "-c:v", "libx264",
                "-avcintra-class", "100",
                "-pix_fmt", "yuv422p10le",
                "-color_primaries", "bt709",
                "-color_trc", "bt709",
                "-colorspace", "bt709",
                "-c:a", "pcm_s16le",
                "-ar", "48000"
            ])
        elif codec_format == "MXF • DNxHR HQ":
            cmd.extend([
                "-c:v", "dnxhd",
                "-profile:v", "dnxhr_hq",
                "-pix_fmt", "yuv422p",
                "-c:a", "pcm_s16le",
                "-ar", "48000"
            ])
        else:
            # Fallback
            cmd.extend([
                "-c:v", "libx264",
                "-crf", str(DEFAULT_CRF),
                "-pix_fmt", "yuv420p",
                "-c:a", "aac"
            ])
            
        cmd.append(output_path)

    return cmd
