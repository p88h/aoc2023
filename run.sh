suffix=pc
if [ `uname` == "Darwin" ]; then
    suffix="mac"
fi
echo $suffix

( echo $1.py; python3 $1.py ) | tee -a all_python3_$suffix.txt
( echo $1.py; pypy3 $1.py ) | tee -a all_pypy3_$suffix.txt
( echo $1.mojo; mojo $1.mojo ) | tee -a all_mojo_$suffix.txt