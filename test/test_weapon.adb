with AUnit.Run;
with AUnit.Reporter.Text;
with Geozone_Suite;

procedure Test_Weapon is
   procedure Run is new AUnit.Run.Test_Runner (Geozone_Suite.Suite);
   Reporter : AUnit.Reporter.Text.Text_Reporter;
begin
   Run (Reporter);
end Test_Weapon;
