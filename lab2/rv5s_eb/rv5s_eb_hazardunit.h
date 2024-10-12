#pragma once

#include "../riscv.h"

#include "VSRTL/core/vsrtl_component.h"

namespace vsrtl {
namespace core {
using namespace Ripes;

//---------------Part 2, TODO: implement earlier branch resolving ----------
// Hint: the existing ports of hzunit now is not enough for detecting hazard. So
// you need to find out what else you need and add input ports in hzunit.
// you are free to modify the lambda expr here

class HazardEBUnit : public Component {
public:
  HazardEBUnit(const std::string &name, SimComponent *parent)
      : Component(name, parent) {
    /*
    hazardFEEnable << [=] { return !hasHazard(); };
    hazardIDEXEnable << [=] { return !hasEcallHazard(); };
    hazardEXMEMClear << [=] { return hasEcallHazard(); };
    hazardIDEXClear << [=] { return hasLoadEXUseHazard(); };
    stallEcallHandling << [=] { return hasEcallHazard(); };
    */

    hazardFEEnable << [=] {return !(hasLoadUseHazard() || hasBranchHazard() || hasJumpHazard() || hasEcallHazard()); };
    hazardIDEXEnable << [=] {return !hasEcallHazard(); };
    hazardIDEXClear << [=] {return (hasLoadUseHazard() ||hasBranchHazard() || hasJumpHazard()); };
    hazardEXMEMClear << [=] {return hasEcallHazard(); };
    stallEcallHandling << [=] {return hasEcallHazard(); };
    controlflowHazard << [=] {return hasBranchHazard() || hasJumpHazard(); };
  }

  INPUTPORT(id_reg1_idx, c_RVRegsBits);
  INPUTPORT(id_reg2_idx, c_RVRegsBits);

  INPUTPORT(ex_reg_wr_idx, c_RVRegsBits);
  INPUTPORT(ex_do_mem_read_en, 1);
  INPUTPORT(ex_do_reg_write, 1);

  INPUTPORT(mem_reg_wr_idx, c_RVRegsBits);
  INPUTPORT(mem_do_mem_read_en, 1);
  INPUTPORT(mem_do_reg_write, 1);

  INPUTPORT(wb_reg_wr_idx, c_RVRegsBits);
  INPUTPORT(wb_do_reg_write, 1);

  INPUTPORT_ENUM(ex_opcode, RVInstr);
  INPUTPORT_ENUM(id_opcode, RVInstr);

  // Hazard Front End enable: Low when stalling the front end (shall be
  // connected to a register 'enable' input port). 
  OUTPUTPORT(hazardFEEnable, 1);

  // Hazard IDEX enable: Low when stalling due to an ECALL hazard
  OUTPUTPORT(hazardIDEXEnable, 1);
  // IDEX clear: High when a load-use/branch/jump (branch/jump hz = alures hz) hazard is detected
  OUTPUTPORT(hazardIDEXClear, 1);

  // EXMEM clear: High when an ECALL hazard is detected
  OUTPUTPORT(hazardEXMEMClear, 1);

  // Stall Ecall Handling: High whenever we are about to handle an ecall, but
  // have outstanding writes in the pipeline which must be comitted to the
  // register file before handling the ecall.
  OUTPUTPORT(stallEcallHandling, 1);

  //
  OUTPUTPORT(controlflowHazard, 1);

private:
  //bool hasHazard() { return hasLoadEXUseHazard() || hasEcallHazard(); }

  /*
  bool hasLoadEXUseHazard() const {
    const unsigned exidx = ex_reg_wr_idx.uValue();
    const unsigned idx1 = id_reg1_idx.uValue();
    const unsigned idx2 = id_reg2_idx.uValue();
    const bool mrd = ex_do_mem_read_en.uValue();

    return (exidx == idx1 || exidx == idx2) && mrd;
  }*/

  bool hasLoadUseHazard() const{
    if (id_opcode.uValue() == RVInstr::JAL ||
        id_opcode.uValue() == RVInstr::JALR ||
        id_opcode.uValue() == RVInstr::BEQ ||
        id_opcode.uValue() == RVInstr::BNE ||
        id_opcode.uValue() == RVInstr::BLT ||
        id_opcode.uValue() == RVInstr::BGE ||
        id_opcode.uValue() == RVInstr::BLTU ||
        id_opcode.uValue() == RVInstr::BGEU) {
      return 0;
    }
    const unsigned exidx = ex_reg_wr_idx.uValue();
    const unsigned idx1 = id_reg1_idx.uValue();
    const unsigned idx2 = id_reg2_idx.uValue();
    const bool mrd = ex_do_mem_read_en.uValue();

    return (exidx != 0) && (exidx == idx1 || exidx == idx2) && mrd;
  }

  bool hasBranchHazard() const{
    if (id_opcode.uValue() == RVInstr::BEQ ||
        id_opcode.uValue() == RVInstr::BNE ||
        id_opcode.uValue() == RVInstr::BLT ||
        id_opcode.uValue() == RVInstr::BGE ||
        id_opcode.uValue() == RVInstr::BLTU ||
        id_opcode.uValue() == RVInstr::BGEU) {
      const unsigned exidx = ex_reg_wr_idx.uValue();
      const unsigned memidx = mem_reg_wr_idx.uValue();
      const unsigned idx1 = id_reg1_idx.uValue();
      const unsigned idx2 = id_reg2_idx.uValue();
      if (ex_do_reg_write.uValue() && (exidx != 0) && (exidx == idx1 || exidx == idx2)) {
        return 1;
      } else if (mem_do_mem_read_en.uValue() && (memidx != 0) &&
                 (memidx == idx1 || memidx == idx2)) {
        return 1;
      } else {
        return 0;
      }
    } else {
      return 0;
    }
  }

  bool hasJumpHazard() const{
    if (id_opcode.uValue() == RVInstr::JAL ||
        id_opcode.uValue() == RVInstr::JALR) {
      const unsigned exidx = ex_reg_wr_idx.uValue();
      const unsigned memidx = mem_reg_wr_idx.uValue();
      const unsigned idx1 = id_reg1_idx.uValue();
      if (ex_do_reg_write.uValue() && (exidx != 0) && (exidx == idx1)) {
        return 1;
      } else if (mem_do_mem_read_en.uValue() && (memidx != 0) && (memidx == idx1)) {
        return 1;
      } else {
        return 0;
      }
    } else {
      return 0;
    }
  }

  bool hasEcallHazard() const {
    // Check for ECALL hazard. We are implictly dependent on all registers when
    // performing an ECALL operation. As such, all outstanding writes to the
    // register file must be performed before handling the ecall. Hence, the
    // front-end of the pipeline shall be stalled until the remainder of the
    // pipeline has been cleared and there are no more outstanding writes.
    const bool isEcall = ex_opcode.uValue() == RVInstr::ECALL;
    return isEcall && (mem_do_reg_write.uValue() || wb_do_reg_write.uValue());
  }
};
} // namespace core
} // namespace vsrtl
