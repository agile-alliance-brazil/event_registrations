module ApplicationHelper
  def autotab
    @current_tab ||= 0
    @current_tab += 1
  end

  def sortable_column(text, column, parameters=request.parameters)
    if(parameters[:column] == column.to_s)
      direction = parameters[:direction] == 'down' ? 'up' : 'down'
    else
      direction = 'down'
    end
    link_to text, parameters.merge(:column => column, :direction => direction, :page => nil)
  end
end
