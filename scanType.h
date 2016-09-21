#ifndef SCANTYPEH
#define SCANTYPEH

#define MAX_SIBLINGS 100
#define MAX_CHILDREN 25

namespace nodes {
    typedef enum {
        Statement,
        Expression,
        Function,
        ParamList,
        Parameter,
        Operator,
        Identifier,
        Constant,
        Assignment,
        AddAssignment,
        SubAssignment,
        MulAssignment,
        DivAssignment,
        IncrementAssignment,
        DecrementAssignment,
        Compound,
        Variable,
        Type,
        IfStatement,
        WhileStatement,
        Return,
        ReturnStatement,
        Break,
        FunctionCall,
        Record,
        Error,
        Empty
    } NodeType;
}

struct TokenData {
    int tokenClass;
    int lineno;
    char* tokenString;
    const char* tokenStringRep;

    bool bval;
    int  ival;
    char cval;

    int relopval;
    const char* relopString; 
    const char* recordType;

    bool isRecord;
    bool isStatic;
};

typedef struct treeNode {
    struct treeNode *children[MAX_CHILDREN]; 
    struct treeNode *sibling;
    nodes::NodeType nodeType;
    int numChildren;
    int siblingIndex;

    const char* tokenString;
    int lineno;

    const char* id;
    const char* type;
    const char* returnType;

    bool isStatic;
    bool isArray;
    int arraySize;
    int nodeId;
} Node;

#endif
