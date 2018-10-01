class Date
  def inspect
    "#<Date: #{self.strftime('%d/%m/%y')}>"
  end
end