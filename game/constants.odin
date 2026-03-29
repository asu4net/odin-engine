package game

WINDOW_TITLE  :: "Game"
WINDOW_WIDTH  :: 1280
WINDOW_HEIGHT :: 720

when ODIN_OS != .Darwin {
    OPENGL_LAST_FEATURES :: true
    OPENGL_MAJOR         :: 4
    OPENGL_MINOR         :: 6
} else {
    OPENGL_LAST_FEATURES :: false
    OPENGL_MAJOR         :: 4
    OPENGL_MINOR         :: 1
}

float4 :: [4] f32
float3 :: [3] f32
float2 :: [2] f32

COLOR_WHITE             :: float4 { 1.0000, 1.0000, 1.0000, 1.0000 }
COLOR_WHITE_FADED       :: float4 { 1.0000, 1.0000, 1.0000, 0.0000 }
COLOR_BLACK             :: float4 { 0.0000, 0.0000, 0.0000, 1.0000 }
COLOR_CORN_FLOWER_BLUE  :: float4 { 0.3880, 0.5840, 0.9330, 1.0000 }
COLOR_BLUE              :: float4 { 0.0000, 0.0000, 1.0000, 1.0000 }
COLOR_LIGHT_BLUE        :: float4 { 0.3000, 0.3000, 1.0000, 1.0000 }
COLOR_CYAN              :: float4 { 0.0000, 1.0000, 1.0000, 1.0000 }
COLOR_GRAY              :: float4 { 0.5000, 0.5000, 0.5000, 1.0000 }
COLOR_DARK_GRAY         :: float4 { 0.2000, 0.2000, 0.2000, 1.0000 }
COLOR_GREEN             :: float4 { 0.0000, 1.0000, 0.0000, 1.0000 }
COLOR_LIGHT_GREEN       :: float4 { 0.3000, 1.0000, 0.3000, 1.0000 }
COLOR_CHILL_GREEN       :: float4 { 0.0471, 0.6510, 0.4078, 1.0000 }
COLOR_MAGENTA           :: float4 { 1.0000, 0.0000, 1.0000, 1.0000 }
COLOR_RED               :: float4 { 1.0000, 0.0000, 0.0000, 1.0000 }
COLOR_LIGHT_RED         :: float4 { 1.0000, 0.3000, 0.3000, 1.0000 }
COLOR_YELLOW            :: float4 { 1.0000, 0.9200, 0.0160, 1.0000 }
COLOR_ORANGE            :: float4 { 0.9700, 0.6000, 0.1100, 1.0000 }

DIR_ZERO   :: float3 { +0.0, +0.0, +0.0 }
DIR_ONE    :: float3 { +1.0, +1.0, +0.0 }
DIR_RIGHT  :: float3 { +1.0, +0.0, +0.0 }
DIR_LEFT   :: float3 { -1.0, +0.0, +0.0 }
DIR_UP     :: float3 { +0.0, +1.0, +0.0 }
DIR_DOWN   :: float3 { +0.0, -1.0, +0.0 }
DIR_FRONT  :: float3 { +0.0, +0.0, +1.0 }
DIR_BACK   :: float3 { +0.0, +0.0, -1.0 }