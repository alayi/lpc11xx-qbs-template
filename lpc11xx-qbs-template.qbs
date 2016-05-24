import qbs
import qbs.FileInfo
import qbs.ModUtils

CppApplication {
    id: app
    name: "project_lpc1114"
    type: ["application", name]
    consoleApplication: true

    cpp.positionIndependentCode: false
    cpp.includePaths: [
        "src/app",
        "src/lib/cmsis"
    ]
    cpp.defines: [
    ]
    cpp.commonCompilerFlags: [
        "-mcpu=cortex-m0",
        "-mthumb",
        "-fno-common",
        "-fmessage-length=0",
        "-fno-exceptions",
        "-ffunction-sections",
        "-fdata-sections"
    ]
    cpp.linkerFlags: [
        "-mcpu=cortex-m0",
        "-mthumb",
        "-nostartfiles",
        "-Wl,--gc-sections",
        "-Wl,-Map=" + destinationDirectory + "/" + name + ".map",
        "-lgcc",
    ]

    Properties {
        condition: qbs.buildVariant === "debug"
        cpp.debugInformation: true
        cpp.optimization: "none"
        cpp.defines: outer.concat("DEBUG")
    }

    Properties {
        condition: qbs.buildVariant === "release"
        cpp.debugInformation: false
        cpp.optimization: "small"
    }

    // Группируем файлы с исходным кодом в группу "sources"
    Group {
        name: "sources"
        prefix: "src/**/"
        files: [
            "*.c",
            "*.cpp",
            "*.h",
            "*.s"
        ]
        cpp.cxxFlags: [ "-std=c++11" ]
        cpp.cFlags: [ "-std=gnu99" ]
        cpp.warningLevel: "all"
    }

    // Группируем скрипты линковщика в группу "ldscripts"
    Group {
        name: "linkerscripts"
        prefix: "./**/"
        files: "*.ld"
        fileTags: ["linkerscript"]
    }

    // Автоматически после успешной сборки:
    // 1. Получение размера прошивки с помощью утилиты size из состава инструментария GCC
    // 2. Создание копии прошивки в популярном формате Intel HEX
    Rule {
        id: postprocess

        //condition: qbs.buildVariant === "release"

        inputs: ["application"]

        Artifact {
            fileTags: [app.name]
            filePath: input.baseDir + "/" + input.baseName + "_firmware"
        }

        prepare: {
            // Вывести размеры секций
            var cmdSize = new Command("arm-none-eabi-size", [input.filePath]);
            cmdSize.description = "Size of sections:";
            cmdSize.highlight = "linker";

            // Создать копию в формате Intel HEX
            var objCopyPath = "arm-none-eabi-objcopy";
            var cmdConvHex = new Command(objCopyPath, ["-O", "ihex", input.filePath, output.filePath + ".hex"]);
            cmdConvHex.description = "Generating HEX file: " + FileInfo.fileName(input.filePath);
            cmdConvHex.highlight = "filegen";

            // Выполнить последовательно все 2 действия
            return [cmdSize, cmdConvHex];
        }
    }
}
