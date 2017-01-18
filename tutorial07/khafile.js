var project = new Project('Empty');

project.addSources('Sources');
project.addShaders('Sources/Shaders/**');
project.addAssets('Assets/**');
project.addLibrary("khage");

resolve(project);