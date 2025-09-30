dump -file waves.fsdb -type FSDB
dump -add testbench -fsdb_opt +mda+packedmda+struct+all+sva -depth 0

run
