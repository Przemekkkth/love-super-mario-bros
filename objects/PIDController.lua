PIDController = Object:extend()

function PIDController:new(kP, kI, kD)
    self.kP = kP
    self.kI = kI
    self.kD = kD

    self.period = 1.0
  
    self.minIntegral = -1.0
    self.maxIntegral = 1.0
 
    self.setpoint = 0
    self.totalError = 0
    self.velocityError = 0
    self.positionError = 0
end

function PIDController:new(kP, kI, kD, period)
    self.kP = kP
    self.kI = kI
    self.kD = kD
    self.period = period

    self.period = 1.0
  
    self.minIntegral = -1.0
    self.maxIntegral = 1.0
 
    self.setpoint = 0
    self.totalError = 0
    self.velocityError = 0
    self.positionError = 0
end

function PIDController:clamp(value, low, high)
    return math.max(low, math.min(value, high))
end

function PIDController:calculate(measurement)
    self.positionError = self.setpoint - measurement
    self.velocityError = (self.setpoint - measurement) / self.period
    if self.kI ~= 0 then
        self.totalError = self:clamp(self.totalError + self.velocityError * self.period, self.minIntegral / self.kI,
                                     self.maxIntegral / self.kI)
    end
    
    return self.positionError * self.kP + self.totalError * self.kI + self.velocityError * self.kD
end

function PIDController:calculateWithSetpoint(measurement, setpoint)
    self.positionError = setpoint - measurement
    self.velocityError = (setpoint - measurement) / self.period
    if self.kI ~= 0 then
        self.totalError = self:clamp(self.totalError + self.velocityError * self.period, self.minIntegral / self.kI,
                                     self.maxIntegral / self.kI)
    end

    return (self.positionError * self.kP) + (self.totalError * self.kI) + (self.velocityError * self.kD)
end

function PIDController:setSetpoint(seatpoint)
    self.seatpoint = seatpoint
end
  