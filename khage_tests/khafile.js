var project = new Project('Khage Tests');

project.addSources('Sources');
project.addShaders('Shaders');
project.addAssets('Assets');
project.addLibrary("khage");
project.addParameter("-D use_khage");

resolve(project);