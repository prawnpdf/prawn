require 'prawn/measurements'

class Numeric
  include Prawn::Measurements        
  # prawns' basic unit is PostScript-Point        
  # 72 points per inch

  def mm
    return mm2pt(self)
  end

  def cm
    return cm2pt(self)
  end

  def dm
    return dm2pt(self)
  end

  def m
    return m2pt(self)
  end

  def in
    return in2pt(self)
  end

  def yd
    return yd2pt(self)
  end

  def ft
    return ft2pt(self)
  end
  
  def pt
    return self
  end
end        
