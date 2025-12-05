local KalmanFilter = { }
KalmanFilter.__index = KalmanFilter

function KalmanFilter:Create(volt, process)
    local object = setmetatable({
        volt = volt or 0.25,
        process = process or 0.05,
        Pc = 0,
        G = 0,
        P = 1,
        Xe = 0
    }, KalmanFilter)

    return object
end

function KalmanFilter:SetVolt(volt)
    if TypeID(volt) ~= TYPE_NUMBER then
        return
    end

    self.volt = volt
end

function KalmanFilter:GetVolt()
    return self.volt
end

function KalmanFilter:SetProcess(process)
    if TypeID(process) ~= TYPE_NUMBER then
        return
    end

    self.process = process
end

function KalmanFilter:GetProcess()
    return self.process
end

function KalmanFilter:Filter(value)
    self.Pc = self.P + self.process
    self.G = self.Pc / (self.Pc + self.volt)
    self.P = (1 - self.G) * self.Pc
    self.Xe = self.G * (value - self.Xe) + self.Xe

    return self.Xe
end

function KalmanFilter:GetLastValue()
    return self.Xe
end

kalman = { }

function kalman.Create(volt, process)
    return KalmanFilter:Create(volt, process)
end