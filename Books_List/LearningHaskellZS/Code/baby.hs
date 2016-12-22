doubleMe x = x + x

doubleUs x y = x*2 + y*2

doubleSmallNumber x = if x > 100
                    then x
                    else x*2

cannanO'Brien = "It's a-me, Canan O'Brien!"

boomBangs xs = [ if x < 10 then "BOOM!" else "BANG!" | x <- xs, odd x ]

removeNonUppercase st = [ c | c <- st, c `elem` ['A'..'Z']]

lucky :: (Integral a) => a -> String   
lucky 7 = "LUCKY NUMBER SEVEN!"   
lucky x = "Sorry, you're out of luck, pal!"

factorial :: (Integral a) => a -> a
factorial 0 = 1
factorial n = n * factorial ( n - 1 )


