#include <iostream>


int main()
{
    std::string name;
    std::cin >> name;
    // vector is auto-imported via stdc++.h
    std::vector<int> v; 
    v.push_back(1);
    std::cout << "Hello, " << name << '\n';
    return 0;
}
