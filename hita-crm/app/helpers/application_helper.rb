module ApplicationHelper
  def sanitize_sql_like(string, escape_character = "\\")
    pattern = Regexp.union(escape_character, "%", "_")
    string.gsub(pattern) { |x| [escape_character, x].join }
  end

  def convert_br_currency_to_float str
  	return '' if str.nil?
  	return str.to_f if is_valid_float(str)
  	return str.remove('R$','US$',' ', '.').gsub(',', '.').to_f
  end

  def is_valid_float str
    !!Float(str) rescue false
  end

  def print_money_alignment number
    return "<div class='money-alignment'><div>R$</div><div>#{ number_to_currency(number, format: '%n') }</div></div>".html_safe
  end
end
