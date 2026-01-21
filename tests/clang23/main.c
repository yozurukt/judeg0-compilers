#include <stdio.h>

int main()
{
    char name[50];
    scanf("%s", name);
    // strlen comes from string.h which is auto-imported
    int len = strlen(name);
    printf("Hello, %s\n", name);
    return 0;
}