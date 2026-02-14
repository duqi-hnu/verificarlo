#!/bin/bash
set -e

source ../paths.sh

if [ -z "${FLANG_PATH}" ]; then
    echo "this test is not run when not using --with-flang"
    # Exit with 77 to mark the test skipped
    # https://www.gnu.org/software/automake/manual/html_node/Scripts_002dbased-Testsuites.html
    exit 77
fi

cat > extension_test_f95.f95 << 'EOF'
program extension_test_f95
  implicit none
  real(8) :: x
  x = 0.1d0 + 0.2d0
  print *, x
end program extension_test_f95
EOF

cat > extension_test_f03.f03 << 'EOF'
program extension_test_f03
  implicit none
  real(8) :: x
  x = 0.1d0 + 0.2d0
  print *, x
end program extension_test_f03
EOF

cat > extension_test_f08.f08 << 'EOF'
program extension_test_f08
  implicit none
  real(8) :: x
  x = 0.1d0 + 0.2d0
  print *, x
end program extension_test_f08
EOF

cat > extension_test_fixed.for << 'EOF'
      program extension_test_fixed
      implicit none
      double precision x
      x = 0.1d0 + 0.2d0
      print *, x
      end
EOF

for source in extension_test_f95.f95 extension_test_f03.f03 extension_test_f08.f08 extension_test_fixed.for; do
    object="${source%.*}.o"
    verificarlo-f -c "$source" -o "$object"
done

verificarlo-f extension_test_f95.o -o extension_test_f95
VFC_BACKENDS="libinterflop_ieee.so" ./extension_test_f95 > output.txt

if [ ! -s output.txt ]; then
    echo "Fortran extension test produced empty output"
    exit 1
fi

echo "Fortran extension support test succeeded"
exit 0
