#include <gtest/gtest.h>

#include <iostream>

#include <neumann.hpp>

TEST(ExpectCorrect, Succeed)
{
    std::cout << "Neumann " << Neumann::Version() << std::endl;
    EXPECT_EQ(true, true);
}
