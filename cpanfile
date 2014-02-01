requires "DDP" => "0";
requires "DateTime" => "0";
requires "Hash::Merge" => "0";
requires "Mojo::Base" => "0";
requires "Skryf::Util" => "0";

on 'test' => sub {
  requires "FindBin" => "0";
  requires "List::Util" => "0";
  requires "Mojolicious" => "0";
  requires "Test::Mojo" => "0";
  requires "Test::More" => "0";
  requires "Test::NoTabs" => "0";
  requires "lib" => "0";
  requires "strict" => "0";
  requires "warnings" => "0";
};

on 'configure' => sub {
  requires "ExtUtils::MakeMaker" => "6.30";
};

on 'develop' => sub {
  requires "Test::More" => "0";
  requires "Test::NoTabs" => "0";
};
