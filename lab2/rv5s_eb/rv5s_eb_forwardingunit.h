#pragma once

#include "../riscv.h"

#include "VSRTL/core/vsrtl_component.h"

namespace vsrtl {
namespace core {
using namespace Ripes;

class ForwardingEBUnit : public Component {
public:
  ForwardingEBUnit(const std::string &name, SimComponent *parent)
      : Component(name, parent) {
    alu_reg1_forwarding_ctrl << [=] {
      if (ex_opcode.uValue() == RVInstr::JAL || ex_opcode.uValue() == RVInstr::JALR ||
          ex_opcode.uValue() == RVInstr::BEQ || ex_opcode.uValue() == RVInstr::BNE ||
          ex_opcode.uValue() == RVInstr::BLT || ex_opcode.uValue() == RVInstr::BGE ||
          ex_opcode.uValue() == RVInstr::BLTU ||
          ex_opcode.uValue() == RVInstr::BGEU) {
        return ForwardingSrc::IdStage;
      }
      const auto idx = id_reg1_idx.uValue();
      if (idx == 0) {
        return ForwardingSrc::IdStage;
      } else if (idx == mem_reg_wr_idx.uValue() && mem_reg_wr_en.uValue()) {
        return ForwardingSrc::MemStage;
      } else if (idx == wb_reg_wr_idx.uValue() && wb_reg_wr_en.uValue()) {
        return ForwardingSrc::WbStage;
      } else {
        return ForwardingSrc::IdStage;
      }
    };

    alu_reg2_forwarding_ctrl << [=] {
      if (ex_opcode.uValue() == RVInstr::JAL || ex_opcode.uValue() == RVInstr::JALR ||
          ex_opcode.uValue() == RVInstr::BEQ || ex_opcode.uValue() == RVInstr::BNE ||
          ex_opcode.uValue() == RVInstr::BLT || ex_opcode.uValue() == RVInstr::BGE ||
          ex_opcode.uValue() == RVInstr::BLTU ||
          ex_opcode.uValue() == RVInstr::BGEU) {
        return ForwardingSrc::IdStage;
      }
      const auto idx = id_reg2_idx.uValue();
      if (idx == 0) {
        return ForwardingSrc::IdStage;
      } else if (idx == mem_reg_wr_idx.uValue() && mem_reg_wr_en.uValue()) {
        return ForwardingSrc::MemStage;
      } else if (idx == wb_reg_wr_idx.uValue() && wb_reg_wr_en.uValue()) {
        return ForwardingSrc::WbStage;
      } else {
        return ForwardingSrc::IdStage;
      }
    };
    //---------------Part 2, TODO: implement earlier branch resolving ----------
    // Hint: forwarding logic like above
    // you can add/remove ports
    br_reg1_forwarding_ctrl << [=] {
      if (id_opcode.uValue() == RVInstr::JAL || id_opcode.uValue() == RVInstr::JALR ||
          id_opcode.uValue() == RVInstr::BEQ || id_opcode.uValue() == RVInstr::BNE ||
          id_opcode.uValue() == RVInstr::BLT || id_opcode.uValue() == RVInstr::BGE ||
          id_opcode.uValue() == RVInstr::BLTU ||
          id_opcode.uValue() == RVInstr::BGEU) {
        const auto idx = br_id_reg1_idx.uValue();
        if(idx == 0){
          return ForwardingSrc::IdStage;
        } else if (idx == mem_reg_wr_idx.uValue() && (mem_reg_wr_en.uValue() && !mem_mem_do_read.uValue()) ){
          return ForwardingSrc::MemStage;
        } else if (idx == mem_reg_wr_idx.uValue() && mem_reg_wr_en.uValue()){
          return ForwardingSrc::WbStage;
        } else {
          return ForwardingSrc::IdStage;
        }
      }
      else{
        return ForwardingSrc::IdStage;
      }
    };

    br_reg2_forwarding_ctrl << [=] {
      if (id_opcode.uValue() == RVInstr::BEQ || id_opcode.uValue() == RVInstr::BNE ||
          id_opcode.uValue() == RVInstr::BLT || id_opcode.uValue() == RVInstr::BGE ||
          id_opcode.uValue() == RVInstr::BLTU ||
          id_opcode.uValue() == RVInstr::BGEU) {
        const auto idx = br_id_reg2_idx.uValue();
        if (idx == 0) {
          return ForwardingSrc::IdStage;
        } else if (idx == mem_reg_wr_idx.uValue() &&
                   (mem_reg_wr_en.uValue() && !mem_mem_do_read.uValue())) {
          return ForwardingSrc::MemStage;
        } else if (idx == mem_reg_wr_idx.uValue() && mem_reg_wr_en.uValue()) {
          return ForwardingSrc::WbStage;
        } else {
          return ForwardingSrc::IdStage;
        }
      } else {
        return ForwardingSrc::IdStage;
      }
    };
  }

  INPUTPORT(id_reg1_idx, c_RVRegsBits);
  INPUTPORT(id_reg2_idx, c_RVRegsBits);

  //INPUTPORT(id_br_reg1_idx, c_RVRegsBits);
  //INPUTPORT(id_br_reg2_idx, c_RVRegsBits);

  INPUTPORT(mem_reg_wr_idx, c_RVRegsBits);
  INPUTPORT(mem_reg_wr_en, 1);

  INPUTPORT(wb_reg_wr_idx, c_RVRegsBits);
  INPUTPORT(wb_reg_wr_en, 1);


  INPUTPORT(br_id_reg1_idx, c_RVRegsBits);
  INPUTPORT(br_id_reg2_idx, c_RVRegsBits);

  INPUTPORT(mem_mem_do_read, 1);

  INPUTPORT_ENUM(id_opcode, RVInstr);
  INPUTPORT_ENUM(ex_opcode, RVInstr);

  OUTPUTPORT_ENUM(alu_reg1_forwarding_ctrl, ForwardingSrc);
  OUTPUTPORT_ENUM(alu_reg2_forwarding_ctrl, ForwardingSrc);
  OUTPUTPORT_ENUM(br_reg1_forwarding_ctrl, ForwardingSrc);
  OUTPUTPORT_ENUM(br_reg2_forwarding_ctrl, ForwardingSrc);
};
} // namespace core
} // namespace vsrtl
