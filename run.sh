suffix=pc
if [ `uname` == "Darwin" ]; then
    suffix="mac"
fi
echo $suffix

( echo day$1.py; python3 day$1.py ) | tee -a all_python3_$suffix.txt
( echo day$1.py; pypy3 day$1.py ) | tee -a all_pypy3_$suffix.txt
( echo day$1.mojo; mojo day$1.mojo ) | tee -a all_mojo_$suffix.txt
