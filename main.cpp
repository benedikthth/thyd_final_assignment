#include <iostream>
#include <fstream>
#include "bparser.h"
#include "symbol_table.h"

using namespace std;


std::string name_without_extension(const std::string& filename) {
    size_t lastdot = filename.find_last_of(".");
    if (lastdot == std::string::npos) return filename;
    return filename.substr(0, lastdot);
}

void print_indented( const std::string& str, ostream& os )
{
    const int IndentLevel = 3;
    int indent = 0;
    for ( auto c : str ) {
        if ( c == '(' ) {
            os << '\n';
            for ( int j=0; j<indent; ++j ) { os << ' '; }
            indent += IndentLevel;
        }
        else if ( c == ')' ) {
            indent -= IndentLevel;
        }
        os << c;
    }
    os << std::endl;
}


int main(int argc, char* argv[])
{
    // Process the command-line arguments, if any.
    // Usage: program [ option [ filename ] ]  (option -s -a )
    bool output_sym_table = false;
    bool output_ast = false;
    if ( argc >= 2 ) {
        if ( string(argv[1]) == "-s" ) { output_sym_table = true; }
        if ( string(argv[1]) == "-a" ) { output_ast = true; }
    }

    string filename( "test.decaf" );
    if ( argc >= 3 ) {
        filename = argv[2];
    }

    // Open file with Decaf program, exit if error opening file.
    FILE* file = fopen( filename.c_str(), "r" );
    if ( file == nullptr ) {
        cerr << "Could not open input file '" << filename << "'." << endl;
        return -1;
    }

    // Instantiate the parser.
    Parser* parser = new BParser(file, false, false); // Change flags to true for debugging.

    // Parse and output the generated abstract syntax tree.
    cout << "====> PARSING FILE " << filename
         << " USING PARSER " << parser->get_name() << endl;
    parser->parse();
    Node *ast = parser->get_AST();
    if ( output_ast ) {
        cout << "====> AST" << endl;
        if ( ast != nullptr ) {
            print_indented( ast->str( ), std::cout );
        }
    }

    std::string tacfilename = name_without_extension(filename) + ".tac";
    cout << "====> TAC --> " << tacfilename << endl;
    SymbolTable st;
    Data data( st );
    TAC tac;
    if ( ast != nullptr ) {
        ast->icg( data, tac );
        ofstream fs(tacfilename);
        tac.output(fs);
        fs.close();
    }

    if ( output_sym_table ) {
        cout << "====> SYMBOL-TABLE" << endl;
        cout << "\nSymbol table (" << st.size() << "):" << endl;
        list<SymbolTable::Entry> L = st.entries();
        for ( auto elem : L ) {
            cout << SymbolTable::to_str(elem) << endl;
        }
    }

    // Clean up and return.
    fclose(file);
    delete parser;
    return 0;
}