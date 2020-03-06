export LC_COLLATE='C'
export LC_CTYPE='C'

grep -rl ".swift" `pwd` | xargs sed -i "" 's/2019 AELF. All/2019 AELF. All/g'
