function AABBCollision(a, b)
    return a.position.x + a.hitbox.x <= b.position.x + b.hitbox.x + b.hitbox.w and
    a.position.x + a.hitbox.x + a.hitbox.w >= b.position.x + b.hitbox.x and
    a.position.y + a.hitbox.y <= b.position.y + b.hitbox.y + b.hitbox.h and
    a.position.y + a.hitbox.y + a.hitbox.h >= b.position.y + b.hitbox.y
end

function AABBCollisionX4(x, y, w, h, b)
    return x <= b.position.x + b.hitbox.x + b.hitbox.w and x + w >= b.position.x + b.hitbox.x and
    y <= b.position.y + b.hitbox.y + b.hitbox.h and y + h >= b.position.y + b.hitbox.y
end

function AABBCollisionX8(x1, y1, w1, h1, x2, y2, w2, h2) 
    return x1 <= x2 + w2 and x1 + w1 >= x2 and y1 <= y2 + h2 and y1 + h1 >= y2
end

function AABBTotalCollision(a, b) 
    return a.position.x + a.hitbox.x < b.position.x + b.hitbox.x + b.hitbox.w and
           a.position.x + a.hitbox.x + a.hitbox.w > b.position.x + b.hitbox.x and
           a.position.y + a.hitbox.y < b.position.y + b.hitbox.y + b.hitbox.h and
           a.position.y + a.hitbox.y + a.hitbox.h > b.position.y + b.hitbox.y
end

function AABBTotalCollisionX4(x, y, w, h, b) 
    return x < b.position.x + b.hitbox.x + b.hitbox.w and x + w > b.position.x + b.hitbox.x and
           y < b.position.y + b.hitbox.y + b.hitbox.h and y + h > b.position.y + b.hitbox.y
end

function AABBTotalCollisionX8(x1, y1, w1, h1, x2, y2, w2, h2)
    return x1 < x2 + w2 and x1 + w1 > x2 and y1 < y2 + h2 and y1 + h1 > y2
end