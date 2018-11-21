loadAIEntity
        clc
    adc AI_offset
    jmp loadEntity
    
updateAIEntity
    jsr setDirection 
    jsr updateEntity
    rts
    
setDirection
    ; find your position relative to the player set your direction towards the player
    rts
    
    
    