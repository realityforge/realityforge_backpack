Belt.scope('realityforge-experiments') do |o|
  # Projects that purely exist so that I can keep a copy of source for reference purposes that are still active
  o.project('Quake2Game', :description => 'A WIP fork of Quake 2 intended to add features more commonly seen in modern game engines.', :tags => %w(external))
  o.project('planet_quake', :description => 'Combination of graphics and features from many different games.', :tags => %w(external))
  o.project('planet_quake_game', :description => 'Game QVMs for many different game dynamics.', :tags => %w(external))
  o.project('RBDOOM-3-BFG', :description => 'Doom 3 BFG Edition with modern engine features (2021) like PBR, Baked Global Illumination, Soft Shadows, Cleaned up source, Linux and 64 bit Support', :tags => %w(external))
  o.project('recastnavigation', :description => 'Navigation-mesh Toolset for Games', :tags => %w(external))

  # Projects that purely exist so that I can keep a copy of source for reference purposes
  o.project('3zb2', :description => '3rd Zigock Bot II for Yamagi Quake II', :tags => %w(external historic))
  o.project('OpenWolf-Engine', :description => 'Heavy modified idTech3 engine', :tags => %w(external historic))
  o.project('q3d3d12', :description => 'Quake III Arena: Ported to D3D12, Xbox One, HoloLens', :tags => %w(external historic default_branch=main))
  # This project's goal is to re-write the bot code in Quake 3 Arena, to use recast navmesh, and make the code generally easier to read and follow.
  o.project('Quake3AI', :description => 'New AI Bot Project for Quake 3 Arena.', :tags => %w(external historic))
  o.project('PreyDoom', :tags => %w(external historic))
  o.project('quake3-brainworks', :tags => %w(external historic))
end
