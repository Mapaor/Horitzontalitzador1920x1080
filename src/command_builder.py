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

    if overlay_path:
        overlay_output = "[tmp]"
    else:
        overlay_output = ""

    if enable_frame:
        ffmpeg_color = frame_color.replace("#", "0x")
        fw2 = frame_width * 2
        foreground = (
            f"[orig]"
            f"scale=-2:{OUTPUT_HEIGHT - fw2},"
            f"pad=iw+{fw2}:ih+{fw2}:{frame_width}:{frame_width}:{ffmpeg_color}"
            f"[foreground]"
        )
        overlay = (
            "[blurred]"
            "[foreground]"
            f"overlay=(W-w)/2:(H-h)/2{overlay_output}"
        )
    else:
        foreground = (
            f"[orig]"
            f"scale=-2:{OUTPUT_HEIGHT}"
            f"[foreground]"
        )
        overlay = (
            "[blurred]"
            "[foreground]"
            f"overlay=(W-w)/2:0{overlay_output}"
        )

    filters = [
        "split[orig][bg]",
        background,
        foreground,
        overlay,
    ]

    if overlay_path:
        if enable_overlay_recolor:
            ffmpeg_recolor = overlay_color.replace("#", "0x")
            filters.append(f"color=c={ffmpeg_recolor}:s={OUTPUT_WIDTH}x{OUTPUT_HEIGHT}:d=1[color_bg]")
            filters.append("[1:v]alphaextract[alpha]")
            filters.append("[color_bg][alpha]alphamerge[colored_overlay]")
            filters.append("[tmp][colored_overlay]overlay=0:0")
        else:
            filters.append("[tmp][1:v]overlay=0:0")

    filter_complex_str = ";".join(filters)

    cmd = [
        str(ffmpeg_path),
        "-y",
        "-i",
        input_path,
    ]

    if overlay_path:
        cmd.extend([
            "-i",
            overlay_path,
        ])

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
        cmd.extend([
            "-c:v",
            "libx264",
            "-crf",
            str(DEFAULT_CRF),
            "-c:a",
            "aac",
            output_path,
        ])

    return cmd
