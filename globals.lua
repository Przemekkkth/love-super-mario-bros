MAX_FPS = 60

ORIGINAL_CUBE_SIZE = 16
CUBE_SCALE_FACTOR = 2
SCALED_CUBE_SIZE = ORIGINAL_CUBE_SIZE * CUBE_SCALE_FACTOR

SCREEN_WIDTH = 25 * SCALED_CUBE_SIZE
SCREEN_HEIGHT = 15 * SCALED_CUBE_SIZE

GRAVITY = 0.575
FRICTION = 0.94
MAX_SPEED_X = 10.00
MAX_SPEED_Y = 7.5
MAX_UNDERWATER_Y = 2.0

MARIO_ACCELERATION_X = 0.24
MARIO_JUMP_ACCELERATION = 1.10
MARIO_BOUNCE = 3.5
ENEMY_BOUNCE = 6.0  -- when jumping on top of enemies
ENEMY_SPEED = 1.0
COLLECTIBLE_SPEED = 2.0
PROJECTILE_SPEED = 10.0
PROJECTILE_BOUNCE = 4.0

TILE_ROUNDNESS = 4

BACKGROUND_COLOR_BLUE = {136 / 255, 188 / 255, 240 / 255}
BACKGROUND_COLOR_BLACK = {0, 0, 0, 255}

DIRECTION = 
{
   NONE = 0,
   UP = 1,
   DOWN = 2,
   LEFT = 3,
   RIGHT = 4
}

COLLISION_DIRECTION =
{
   NONE = 0,
   TOP = 1,
   BOTTOM = 2,
   LEFT = 3,
   RIGHT = 4
}

PLATFORM_MOTION_TYPE =
{
   NONE = 0,
   ONE_DIRECTION_REPEATED = 1,    -- Moves in one direction, but goes to min point when it reaches max
   ONE_DIRECTION_CONTINUOUS = 2,  -- Continuously moving in one direction
   BACK_AND_FORTH = 3,            -- Moves back and forth
   GRAVITY = 4                    -- Affected by Gravity when mario stands on it
}

ROTATION_DIRECTION = 
{
   NONE = 0,
   CLOCKWISE = 1,
   COUNTER_CLOCKWISE = 2
}

MYSTERY_BOX_TYPE =
{
   NONE = 0,
   MUSHROOM = 1,
   COINS = 2,
   SUPER_STAR = 3,
   ONE_UP = 4,
   VINES = 5
}

COLLECTIBLE_TYPE =
{
   NONE = 0,
   MUSHROOM = 1,
   SUPER_STAR = 2,
   FIRE_FLOWER = 3,
   COIN = 4,
   ONE_UP = 5
}

COLLISION_DIRECTION =
{
   NONE = 0,
   TOP = 1,
   BOTTOM = 2,
   LEFT = 3,
   RIGHT = 4
}

PLAYER_STATE =
{
   SMALL_MARIO = 0,
   SUPER_MARIO = 1,
   FIRE_MARIO  = 2
}

ENEMY_TYPE =
{
   NONE = 0,
   BLOOPER = 1,
   BOWSER = 2,
   BULLET_BILL = 3,
   BUZZY_BEETLE = 4,
   CHEEP_CHEEP = 5,
   FIRE_BAR = 6,
   GOOMBA = 7,
   HAMMER_BRO = 8,
   KOOPA = 9,
   KOOPA_PARATROOPA = 10,
   KOOPA_SHELL = 11,
   LAKITU = 12,
   LAVA_BUBBLE = 13,
   PIRANHA_PLANT = 14,
   SPINE = 15
}

PROJECTTILE_TYPE = 
{
   NONE = 0,
   FIREBALL = 1,
   OTHER = 2
}


COLLECTIBLE_TYPE = 
{
   NONE = 0,
   MUSHROOM = 1,
   SUPER_STAR = 2, 
   FIRE_FLOWER = 3,
   COIN = 4,
   ONE_UP = 5
}

WARP_PIPE_DIRECTIONS = 
{
   NONE = 0,
   UP = 1,
   DOWN = 2,
   LEFT = 3,
   RIGHT = 4
}

LEVEL_TYPE =
{
   NONE = 0,
   OVERWORLD = 1,
   UNDERGROUND = 2,
   UNDERWATER = 3,
   CASTLE = 4,
   START_UNDERGROUND = 5
}

ANIMATION_STATE = {
   STANDING = 0,
   WALKING = 1,
   RUNNING = 2,
   DRIFTING = 3,
   DUCKING = 4,
   JUMPING = 5,
   SWIMMING = 6,
   SWIMMING_JUMP = 7,
   SWIMMING_WALK = 8,
   LAUNCH_FIREBALL = 9,
   CLIMBING = 10,  -- Climbing a vine
   SLIDING = 11,   -- Sliding down a flag
   GAMEOVER = 12
}

GROW_TYPE = {
   ONEUP = 0,
   MUSHROOM = 1,
   SUPER_STAR = 2,
   FIRE_FLOWER = 3
}

SOUND_ID = 
{
   BLOCK_BREAK = 0,
   BLOCK_HIT = 1,
   BOWSER_FALL = 2,
   BOWSER_FIRE = 3,
   CANNON_FIRE = 4,
   COIN = 5, 
   DEATH = 6,
   FIREBALL = 7,
   FLAG_RAISE = 8,
   GAME_OVER = 9,
   JUMP = 10,
   KICK = 11,
   ONE_UP = 12,
   PAUSE = 13,
   PIPE = 14,
   POWER_UP_APPEAR = 15,
   POWER_UP_COLLECT = 16,
   SHRINK = 17,
   STOMP = 18,
   TIMER_TICK = 19,
   CASTLE_CLEAR = 20
}

MUSIC_ID = 
{
   OVERWORLD = 0,
   UNDERGROUND = 1,
   CASTLE = 2,
   UNDERWATER = 3,
   SUPER_STAR = 4,
   GAME_WON = 5
}