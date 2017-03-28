module JavaTea
	class TempClass
		attr_reader :pub
		attr_reader :classname, :extends
		attr_accessor :publicVars, :privateVars
		attr_accessor :getsetVars, :getVars, :setVars
		attr_accessor :methods
		def initialize(pub,classname)
			@pub = pub
			@classname, @extends = classname, nil
			@publicVars = []
			@privateVars = []
			@getsetVars = []
			@methods = []
		end

		def extends=(newParent)
			@extends = newParent
		end
	end

	class TempVar
		attr_reader :pub
		attr_reader :type, :varname, :defaultValue
		def initialize(pub, type, varname, defaultValue)
			@pub = pub
			@type, @varname = type, varname
			@defaultValue = defaultValue
		end
	end

	class TempDef
		attr_reader :pub
		attr_reader :type, :defname
		attr_accessor :params
		def initialize(pub, type, defname)
			@pub = pub
			@type, @defname = type, defname
			@params = []
		end
	end

	class << self
		def convert(array)
			@_temp_imports = []
			@_temp_classes = []
			@_temp_global_vars = []

			array.each do |line|
				_make_import(line) 				if line =~ /\*\s?java/i
				_make_public_class(line) 		if line =~ /\+\s?class/i
				_make_private_class(line) 		if line =~ /\-?\s?class/i
				_make_getset_variable(line)		if line =~ /\s*~\s?/i
				_make_get_variable(line)		if line =~ /\s*~g\s?/i
				_make_set_variable(line)		if line =~ /\s*~s\s?/i
				_make_public_method(line)		if line =~ /\s+\+def\s?/i
				_make_private_method(line)		if line =~ /\s+\-?def\s?/i
				_make_public_variable(line)		if line =~ /\s*\+\s?/i
				_make_private_variable(line)	if line =~ /\s*\-\s?/i
			end

			return _write_code
		end

		def convert_file(filename, save = true, saveFmt = "pde")
			array = []
			open(filename, "r") { |io| array = io.readlines }
			result = convert(array)
			if save
				begin
					publicClass = @_temp_classes.select{|klass| klass.pub == true}[0].classname
					open("./#{publicClass}.#{saveFmt}", "w") {|io| io.write result}
				rescue => e
					puts [e.message,e.backtrace].join("\n")
				end
				puts "---\nsaved successful!"
			else
				puts result
			end
		end

		def _make_import(line)
			line.gsub!(/^\*\s?/){""}
			if line =~ /,/
				array = line.split(/,/)
				array.each{|item|item.strip!}
				@_temp_imports += array
			else
				@_temp_imports.push line
			end
		end

		def _make_public_class(line)
			begin
				regexp 	= /\+\s?class\s?([\w_]+)/i
				regexp2 = /\+\s?class\s?(?:[\w_]+)\s?by\s?([\w_]+)/i
				@_temp_classes.push TempClass.new(
					true,
					line.match(regexp)[1]
				)
				if line =~ regexp2
					@_temp_classes.last.extends = line.match(regexp)[1]
				end
			rescue => e 
				puts [e.message,e.backtrace].join("\n")
			end
		end

		def _make_private_class(line)
			return if line.match(/\+\s?class/)
			begin
				regexp 	= /\-?\s?class\s?([\w_]+)/i
				regexp2 = /\-?\s?class\s?(?:[\w_]+)\s?by\s?([\w_]+)/i
				@_temp_classes.push TempClass.new(
					false,
					line.match(regexp)[1]
				)
				if line =~ regexp2
					@_temp_classes.last.extends = line.match(regexp2)[1]
				end
			rescue => e 
				puts [e.message,e.backtrace].join("\n")
			end
		end

		def _make_getset_variable(line)
			if line =~ /^\t/
				begin
					type = line.match(/\s*~\s?([\w_]+)/)[1]
					name = line.match(/\s*~\s?(?:[\w_]+)\s+([\w_]+)/)[1]
					regexp = /\s*~\s?(?:[\w_]+)\s+(?:[\w_]+)\s+([\d\w\"\']+)/

					dval = line.match(regexp) ? $1 : nil
					@_temp_classes.last.getsetVars.push(
						TempVar.new( true, type, name, dval )
					)
				rescue => e 
					puts [e.message,e.backtrace].join("\n")
				end
			else
				begin
					type = line.match(/\s*~\s?([\w_]+)/)[1]
					name = line.match(/\s*~\s?(?:[\w_]+)\s+([\w_]+)/)[1]
					regexp = /\s*~\s?(?:[\w_]+)\s+(?:[\w_]+)\s+([\d\w\"\']+)/

					dval = line.match(regexp) ? $1 : nil
					@_temp_global_vars.push(
						TempVar.new( true, type, name, dval )
					)
				rescue => e 
					puts [e.message,e.backtrace].join("\n")
				end
			end
		end

		def _make_get_variable(line)
			#
		end

		def _make_set_variable(line)
			#
		end

		def _make_public_variable(line)
			if line =~ /^\t/
				begin
					type = line.match(/\s*\+\s?([\w_\[\]]+)/)[1]
					name = line.match(/\s*\+\s?(?:[\w_\[\]]+)\s+([\w_]+)/)[1]
					regexp = /\s*\+\s?(?:[\w_\[\]]+)\s+(?:[\w_]+)\s+([\d\w\"\']+)/

					dval = line.match(regexp) ? $1 : nil
					@_temp_classes.last.publicVars.push(
						TempVar.new( true, type, name, dval )
					)
				rescue => e 
					puts [e.message,e.backtrace].join("\n")
				end
			else
				begin
					type = line.match(/\+\s?([\w_]+)/)[1]
					name = line.match(/\+\s?(?:[\w_]+)\s+([\w_]+)/)[1]
					regexp = /\+\s?(?:[\w_]+)\s+(?:[\w_]+)\s+([\d\w\"\']+)/

					dval = line.match(regexp) ? $1 : nil
					@_temp_global_vars.push(
						TempVar.new( true, type, name, dval )
					)
				rescue => e 
					puts [e.message,e.backtrace].join("\n")
				end
			end
		end

		def _make_private_variable(line)
			return if line =~ /\s+\-?def\s?/
			if line =~ /^\t/
				begin
					type = line.match(/\s*\-\s?([\w_\[\]]+)/)[1]
					name = line.match(/\s*\-\s?(?:[\w_\[\]]+)\s+([\w_]+)/)[1]
					regexp = /\s*\-\s?(?:[\w_\[\]]+)\s+(?:[\w_]+)\s+([\d\w\"\'\.]+)/

					dval = line.match(regexp) ? $1 : nil
					@_temp_classes.last.privateVars.push(
						TempVar.new( false, type, name, dval )
					)
				rescue => e 
					puts [e.message,e.backtrace].join("\n")
				end
			else
				begin
					type = line.match(/\s*\-\s?([\w_]+)/)[1]
					name = line.match(/\s*\-\s?(?:[\w_]+)\s+([\w_]+)/)[1]
					regexp = /\s*\-\s?(?:[\w_]+)\s+(?:[\w_]+)\s+([\d\w\"\']+)/

					dval = line.match(regexp) ? $1 : nil
					@_temp_global_vars.push(
						TempVar.new( false, type, name, dval )
					)
				rescue => e 
					puts [e.message,e.backtrace].join("\n")
				end
			end
		end

		def _make_public_method(line)
			#
		end

		def _make_private_method(line)
			if line =~ /^\t/
				begin
					type = line.match(/\s*\-?def\s?([\w_\[\]]+)/)[1]
					name = line.match(/\s*\-?def\s?(?:[\w_\[\]]+)\s+([\w_]+)/)[1]
					regexp = /\s*\-?def\s?(?:[\w_\[\]]+)\s+(?:[\w_]+)\s+\(([\s\w\,\"\'\.]+)\)/

					array = line.match(regexp) ? $1 : nil
					params = array.split(/,/) if array.is_a? String
					params.each{|item|item.strip!}
					@_temp_classes.last.methods.push(
						TempDef.new( false,
							type,
							name
						)
					)

					# puts @_temp_classes.last.methods.last.inspect
				rescue => e 
					puts [e.message,e.backtrace].join("\n")
				end
			end
		end

		def _write_code
			result = []
			# imports
			if @_temp_imports.size > 0
				@_temp_imports.each do |import|
					result.push("import #{import};")
				end
				result.push("")
			end

			# global vars
			if @_temp_global_vars.size > 0
				result.push("// global")
				@_temp_global_vars.each do |var|
					result.push("#{var.pub ? "public " : ""}#{var.varname};")
				end
				result.push("")
			end

			@_temp_classes.each do |klass|
				# begin
				if @_temp_classes.size > 1
					result.push("/* --- #{klass.classname.upcase} --- */\n")
				end

				result.push(
					[
						"#{klass.pub ? "public " : ""}class #{klass.classname}",
						"#{klass.extends ? " extends #{klass.extends}" : ""} {"
					].join
				)

				# vars
				varSize = 	klass.getsetVars.size +
							klass.publicVars.size +
							klass.privateVars.size
				if varSize > 0
					result.push("\t// variables")
					if klass.publicVars.size > 0
						klass.publicVars.each do |var|
							result.push("\tpublic #{var.type} #{var.varname};")
						end
						result.push("\t")
					end
					if klass.privateVars.size > 0
						klass.privateVars.each do |var|
							result.push("\tprivate #{var.type} #{var.varname};")
						end
						result.push("\t")
					end
					klass.getsetVars.each do |var|
						result.push("\t#{var.type} #{var.varname};")
					end
					result.push("\t")
				end

				# constructor
				result.push("\t// constructor")
				result.push("\tpublic #{klass.classname}() {")
				if varSize > 0
					array_result = _write_code_class_constructor(klass)
					result += array_result.to_a
				end
				result.push("\t}")
				result.push("\t")

				# getters
				if klass.getsetVars.size > 0
					result.push("\t// getters")
					klass.getsetVars.each do |var|
						varname = var.varname.clone
						varname[0] = varname[0].upcase
						result.push(
							[
								"\tpublic #{var.type} get#{varname}() {",
								"\t\treturn #{var.varname};",
								"\t}"
							].join("\n")
						)
					end
					result.push("\t")
				end

				# setters
				if klass.getsetVars.size > 0
					result.push("\t// setters")
					klass.getsetVars.each do |var|
						varname = var.varname.clone
						varname[0] = varname[0].upcase
						result.push(
							[
								"\tpublic #{var.type} set#{varname}(#{var.type} newValue) {",
								"\t\t#{var.varname} = newValue;",
								"\t}"
							].join("\n")
						)
					end
					result.push("\t")
				end

				# functions

				# end
				result.push("}");
				result.push("")
			end
			result.join("\n")
		end

		def _write_code_class_constructor(klass)
			result = []

			if klass.publicVars.size > 0
				klass.publicVars.each do |var|
					array_result = _write_code_variable(var)
					result += array_result.to_a
				end
				result.push("\t\t")
			end
			if klass.privateVars.size > 0
				klass.privateVars.each do |var|
					array_result = _write_code_variable(var)
					result += array_result.to_a
				end
				result.push("\t\t")
			end
			klass.getsetVars.each do |var|
				array_result = _write_code_variable(var)
				result += array_result.to_a
			end

			return result
		end

		def _write_code_variable(var)
			result = []

			if ["int","String","boolean","float","double","char"].include? var.type
				unless var.defaultValue.nil?
					result.push("\t\t#{var.varname} = #{var.defaultValue};")
				end
			else
				if var.defaultValue.nil?
					result.push("\t\t#{var.varname} = new #{var.type}();")
				else
					if var.type =~ /\[\]/
						type = var.type.clone
						type.gsub!(/\[\]/){""}
						result.push("\t\t#{var.type} #{var.varname} = new #{type}[#{var.defaultValue}];")
					else
						result.push("\t\t#{var.type}<#{var.defaultValue}> #{var.varname} = new #{var.type}<>();")
					end
				end
			end

			return result
		end
	end
end

# TEST
array=[
	"* java.io.*, java.util.Properties",
	"+ class Filename",
	"	+ String[] line 10",
	"	~ int some 0",
	"	-def void makeSomeFun (int x, int y)",
	"class Foo",
	"	+ ArrayList some SomeClass",
]

puts JavaTea.convert(array)
JavaTea.convert_file("./example.txt")