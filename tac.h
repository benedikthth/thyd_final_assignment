
#ifndef DECAFPARSER_TAC_H
#define DECAFPARSER_TAC_H

#include <iomanip>
#include <list>
#include <vector>
#include <iostream>
#include <assert.h>

class TAC {
public:

    const std::vector<std::string> IName = {
        "UMINUS", "ADD", "SUB", "MULT", "DIVIDE", "MOD", "AND", "OR", "NOT",
        "CALL", "FPARAM", "APARAM", "RETURN",
        "GOTO", "LT", "LE", "GT", "GE", "EQ", "NE",
        "VAR", "ASSIGN", "NOOP"
    };

    enum InstrType {
        UMINUS, ADD, SUB, MULT, DIVIDE, MOD, AND, OR, NOT,
        CALL, FPARAM, APARAM, RETURN,
        GOTO, LT, LE, GT, GE, EQ, NE,
        VAR, ASSIGN, NOOP
    };


    struct Quad {
        Quad( std::string l, TAC::InstrType t )
                : label(l), type(t) {}
        Quad( std::string l, TAC::InstrType t, std::string r )
                : label(l), type(t), result(r) {}
        Quad( std::string l, TAC::InstrType t, std::string p1, std::string r )
                : label(l), type(t), param1(p1), result(r) {}
        Quad( std::string l, TAC::InstrType t, std::string p1, std::string p2, std::string r )
                : label(l), type(t), param1(p1), param2(p2), result(r) {}

        std::string label;
        TAC::InstrType type;
        std::string param1;
        std::string param2;
        std::string result;
    };

    void clear() {
        program_.clear();
    }

    void append( InstrType itype ) {
        assert( itype == InstrType::NOOP || itype == InstrType::RETURN );
        program_.push_back( Quad( get_label(), itype ) );
    }

    void append( InstrType itype, std::string result ) {
        assert( itype == InstrType::RETURN || itype == InstrType::GOTO ||
                itype == InstrType::VAR    || itype == InstrType::CALL ||
                itype == InstrType::FPARAM || itype == InstrType::APARAM );
        program_.push_back( Quad( get_label(), itype, result) );
    }

    void append( InstrType itype, std::string param1, std::string result ) {
        assert( itype == InstrType::UMINUS || itype == InstrType::NOT ||
                itype == InstrType::ASSIGN );
        program_.push_back( Quad( get_label(), itype, param1, result) );
    }

    void append( InstrType itype, std::string param1, std::string param2, std::string result ) {
        assert( itype == InstrType::ADD  || itype == InstrType::SUB ||
                itype == InstrType::MULT || itype == InstrType::DIVIDE ||
                itype == InstrType::MOD  || itype == InstrType::AND ||
                itype == InstrType::OR   || itype == InstrType::NOT ||
                itype == InstrType::LT   || itype == InstrType::LE  ||
                itype == InstrType::GT   || itype == InstrType::GE  ||
                itype == InstrType::EQ   || itype == InstrType::NE  );
        program_.push_back( Quad( get_label(), itype, param1, param2, result) );
    }

    void end_append() {
        // NOTE: if label.
    }

    void label_next_instr( std::string label ) {
        labels_.push_back( label );
    }

    std::string label_name( const std::string& substr, int no ) {
        return std::string("lab_") + substr + "_" + std::to_string( no );
    }

    std::string tmp_variable_name( int no ) {
        return std::string("t") + std::to_string( no );
    }

    TAC::InstrType  last_instr_type() {
        if ( program_.empty() ) {
            return TAC::InstrType::NOOP;
        }
        return (program_.back()).type;
    }

    void output( std::ostream& os ) {
        for ( auto q : program_ ) {
            if ( q.label.empty() ) {
                os << std::setw(17) << "";
            }
            else {
                std::string label = q.label + ":";
                os << std::setw(17) << std::right << label;
            }
            os << std::setw(8)  << std::right << IName[q.type] << "  "
               << std::setw(17) << q.param1 << "  "
               << std::setw(17) << q.param2 << "  "
               << std::setw(17) << q.result << std::endl;
        }
    }

private:
    std::string get_label() {
        std::string label = "";
        if ( !labels_.empty() ) {
            while ( labels_.size() > 1 ) {
                program_.push_back( Quad( labels_.front(), TAC::InstrType::GOTO, labels_.back() ) );
                labels_.pop_front();
            }
            label = labels_.front();
            labels_.pop_front();
        }
        return label;
    }

    std::list<std::string> labels_;
    std::list<Quad> program_;
};
#endif //DECAFPARSER_TAC_H
