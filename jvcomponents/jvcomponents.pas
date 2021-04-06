{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit jvComponents;

{$warn 5023 off : no warning about unused units}
interface

uses
  JVEdit, MetroButton, MetroCheckbox, JVStringGrid, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('JVEdit', @JVEdit.Register);
  RegisterUnit('MetroButton', @MetroButton.Register);
  RegisterUnit('MetroCheckbox', @MetroCheckbox.Register);
  RegisterUnit('JVStringGrid', @JVStringGrid.Register);
end;

initialization
  RegisterPackage('jvComponents', @Register);
end.
