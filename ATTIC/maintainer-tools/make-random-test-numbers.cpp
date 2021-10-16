// One can use this to generate random numbers for testing.
//
// See https://stackoverflow.com/questions/28115724/getting-big-random-numbers-in-c-c

#include <random>
#include <iostream>

int main()
{
  std::random_device rd;
  std::mt19937 gen(rd());
  std::uniform_int_distribution<unsigned long long>
    dis(0, 0xFFFFFFFFFFFFFFFF);

  for (int n = 0; n < 100; n += 1)
    std::cout << "0x"
              << std::hex 
              << std::uppercase 
              << dis(gen)
              << '\n';
}
