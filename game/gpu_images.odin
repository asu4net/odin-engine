package game

// @Pending: Auto-generate this file in comp-time using the sources folder.

// @Note: Types.
Image_Type :: enum {
    Atlas,
}

// @Note: Read-Only Array.
images := [Image_Type] []u8 {
    .Atlas = #load("gpu_image_00_atlas.png", []u8),
}