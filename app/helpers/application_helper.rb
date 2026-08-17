module ApplicationHelper
  def match_result_label(match)
    { "win" => "[WIN]", "loss" => "[LOSS]", "tie" => "[TIE]" }.fetch(match.result, match.result.to_s.upcase)
  end

  def match_result_color_class(match)
    { "win" => "c-green", "loss" => "c-red", "tie" => "c-blue" }.fetch(match.result, "c-dim")
  end

  def match_result_row_class(match)
    { "win" => "row-win", "loss" => "row-loss", "tie" => "row-tie" }.fetch(match.result, "row-loss")
  end
end
