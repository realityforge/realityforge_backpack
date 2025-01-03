Belt.scope('realityforge-experiments') do |o|
  # Projects that purely exist so that I can keep a copy of source for reference purposes that are still active
  o.project('Narxim-GAS-Example', :description => 'A basic setup for using Epic''s Gameplay Ability System.', :tags => %w(external zim=no))
  o.project('Quake2Game', :description => 'A WIP fork of Quake 2 intended to add features more commonly seen in modern game engines.', :tags => %w(external zim=no))
  o.project('planet_quake', :description => 'Combination of graphics and features from many different games.', :tags => %w(external zim=no))
  o.project('planet_quake_game', :description => 'Game QVMs for many different game dynamics.', :tags => %w(external zim=no))
  o.project('RBDOOM-3-BFG', :description => 'Doom 3 BFG Edition with modern engine features (2021) like PBR, Baked Global Illumination, Soft Shadows, Cleaned up source, Linux and 64 bit Support', :tags => %w(external zim=no))
  o.project('recastnavigation', :description => 'Navigation-mesh Toolset for Games', :tags => %w(external zim=no))
  o.project('BakeMaster-Blender-Addon', :description => 'Welcome to BakeMaster, a powerful and feature-packed baking solution created for Blender - an open-source 3D Computer graphics software.', :tags => %w(external zim=no))
  o.project('WarriorRPG', :description => 'a c++ project showcasing best practices of building complex RPG combat experiences', :tags => %w(external zim=no default_branch=main))

  # Example using a GAS-like mechanism for 
  o.project('Level-Zero', :description => 'CS193U - Videogame Development in Unreal - Project', :tags => %w(external historic zim=no))
  
  # Gas Multiplayer example
  o.project('ue5_gas_multiplayer', :description => 'CS193U - Videogame Development in Unreal - Project', :tags => %w(external historic homepade=https://www.udemy.com/course/advanced-unreal-engine-5-multiplayer-gameplay-programming/))

  # Projects that purely exist so that I can keep a copy of source for reference purposes
  o.project('compiling-unreal', :description => 'A man''s notes as he discovers how Unreal Engine compiles things', :tags => %w(external default_branch=main historic))
  o.project('3zb2', :description => '3rd Zigock Bot II for Yamagi Quake II', :tags => %w(external historic))
  o.project('OpenWolf-Engine', :description => 'Heavy modified idTech3 engine', :tags => %w(external historic))
  o.project('q3d3d12', :description => 'Quake III Arena: Ported to D3D12, Xbox One, HoloLens', :tags => %w(external historic default_branch=main))
  # This project's goal is to re-write the bot code in Quake 3 Arena, to use recast navmesh, and make the code generally easier to read and follow.
  o.project('Quake3AI', :description => 'New AI Bot Project for Quake 3 Arena.', :tags => %w(external historic))
  o.project('PreyDoom', :tags => %w(external historic))
  o.project('quake3-brainworks', :tags => %w(external historic))
  o.project('DNF-IcedTech', :description => 'Duke Nukem Forever IcedTech Branch', :tags => %w(external historic default_branch=main))
  o.project('Quake4BSE', :tags => %w(external historic))
  o.project('baseq3a', :description => 'Unofficial Quake III Arena gamecode patch', :tags => %w(external historic))
  o.project('urbanterror-slim', :description => 'Improved Quake III Arena engine', :tags => %w(external historic))

  o.project('bazel_rules_unreal', :description => 'This repository is the home of the unreal 5 bazel rules', :tags => %w(external historic))
  o.project('bazel-ue5-test-project', :description => 'This project contains data to test the bazel unreal rules', :tags => %w(external historic))
end
