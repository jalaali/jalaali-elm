import List


type alias Date =
  { year : Int
  , month : Int
  , day : Int
  }

gregorian_days_in_month = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
jalali_days_in_month = [31, 31, 31, 31, 31, 31, 30, 30, 30, 30, 30, 29]

calculate_day_and_month remained_days days_in_month_list month = 
  case days_in_month_list of
    [] -> (remained_days + 1, month + 1)
    this_month_days :: rest_year ->
      if remained_days >= this_month_days then
        calculate_day_and_month (remained_days - this_month_days) rest_year (month + 1)
      else
        (remained_days + 1, month + 1)
        

to_jalali : Date -> Date
to_jalali gdate = 
  let
    gd = gdate.day - 1
    gm = gdate.month - 1
    gy = gdate.year - 1600
    g_day_no = gd
      + ( gy * 365)
      + ( gy + 3 ) / 4
      - ( gy + 99 ) / 100
      + ( gy + 399 ) / 400
      + (if (gm > 1 && ((gy % 4 == 0 && gy % 100 /= 0) || (gy % 400 == 0))) then 1 else 0)
      + List.sum (List.take gm gregorian_days_in_month)

    j_np = floor((g_day_no - 79) / 12053)
    j_day_no = ( floor(g_day_no - 79) % 12053 ) % 1461
    jy = 979
      + (33 * j_np)
      + 4 * floor(toFloat(floor(g_day_no - 79) % 12053) / 1461)
      + (if j_day_no >= 365 then floor(toFloat(j_day_no - 1) / 365) else 0)
    
    j_day_no2 = if j_day_no >= 365 then (j_day_no - 1) % 365 else j_day_no
    (jd, jm) = calculate_day_and_month j_day_no2 (List.take 11 jalali_days_in_month) 0
  in
    { gdate | year=jy, month=jm, day=jd }
