import List

type alias Date =
  { year : Int
  , month : Int
  , day : Int
  }


gregorian_days_in_month = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
jalali_days_in_month = [31, 31, 31, 31, 31, 31, 30, 30, 30, 30, 30, 29]


calculate_g2j_day_and_month remained_days days_in_month_list month = 
  case days_in_month_list of
    [] -> (remained_days + 1, month + 1)
    this_month_days :: rest_year ->
      if remained_days >= this_month_days then
        calculate_g2j_day_and_month (remained_days - this_month_days) rest_year (month + 1)
      else
        (remained_days + 1, month + 1)


calculate_j2g_day_and_month remained_days days_in_month_list month leap =
  let
    leap_day = if leap && month == 1 then 1 else 0
  in
    case days_in_month_list of
      [] -> (remained_days + 1, month + 1)
      this_month_days :: rest_year ->
        if remained_days >= (this_month_days + leap_day) then
          calculate_j2g_day_and_month (remained_days - this_month_days - leap_day) rest_year (month + 1) leap
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
      + floor(( toFloat gy + 3 ) / 4)
      - floor(( toFloat gy + 99 ) / 100)
      + floor(( toFloat gy + 399 ) / 400)
      + (if (gm > 1 && ((gy % 4 == 0 && gy % 100 /= 0) || (gy % 400 == 0))) then 1 else 0)
      + List.sum (List.take gm gregorian_days_in_month)

    j_np = floor(toFloat(g_day_no - 79) / 12053)
    j_day_no = ((g_day_no - 79) % 12053 ) % 1461
    jy = 979
      + (33 * j_np)
      + 4 * floor(toFloat((g_day_no - 79) % 12053) / 1461)
      + (if j_day_no >= 365 then floor(toFloat(j_day_no - 1) / 365) else 0)
    
    j_day_no2 = if j_day_no >= 365 then (j_day_no - 1) % 365 else j_day_no
    (jd, jm) = calculate_g2j_day_and_month j_day_no2 (List.take 11 jalali_days_in_month) 0
  in
    { gdate | year=jy, month=jm, day=jd }



to_gregorian jdate =
  let
    jy = jdate.year - 979
    jm = jdate.month - 1
    jd = jdate.day - 1
    j_day_no = jd
      + (365 * jy)
      + floor(jy / 33) * 8
      + floor(toFloat(jy % 33 + 3) / 4)
      + List.sum (List.take jm jalali_days_in_month)


    gy_init = 1600 + 400 * floor(toFloat(j_day_no + 79) / 146097)
    (g_day_no, gy_add, leap) = 
      let
        (g_day_no, gy_add_tmp, leap) = 
          let
            tmp_no_days1 = (j_day_no + 79) % 146097
            tmp_no_days2 = (tmp_no_days1 - 1) % 36524
          in
            if tmp_no_days1 >= 36525 then
              let
                gy_add = floor(toFloat(tmp_no_days1 - 1) / 36524) * 100
              in
                if tmp_no_days2 >= 365 then
                  ((tmp_no_days2 + 1), gy_add, True)
                else
                  (tmp_no_days2, gy_add, False)
            else
              (tmp_no_days1, 0, True)
        gy_add = gy_add_tmp + 4 * floor(toFloat(g_day_no) / 1461)
      in
        if g_day_no >= 366 then
          ((((g_day_no % 1461) - 1) % 365)
          , (gy_add + floor(toFloat((g_day_no % 1461) - 1)/365))
          , False
          )
        else
          (g_day_no % 1461, gy_add, leap)

    gy = gy_init + gy_add 
    
    (gd, gm) = calculate_j2g_day_and_month g_day_no (List.take 11 gregorian_days_in_month) 0 leap
    
  in
    { jdate | year=gy, month=gm, day=gd }

-----------------------------------------------------
-- Usage
-----------------------------------------------------
today: Date
today = {year = 2017, month=6, day=25}

main = 
  text (toString
      [ (to_jalali today)
      , (to_gregorian {year=1396, month=04, day=04})
      ])