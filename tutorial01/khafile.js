var project = new Project('Empty');

project.addSources('Sources');
project.addShaders('Sources/Shaders/**');
project.addLibrary("khage");
project.addParameter("-D dump=pretty")

return project;