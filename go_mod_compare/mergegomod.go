package main

import (
	"bufio"
	"fmt"
	"os"
	"regexp"
	"strings"
)

// Parses a go.mod file and returns a map[modulePath]version
func parseGoMod(path string) (map[string]string, error) {
	file, err := os.Open(path)
	if err != nil {
		return nil, err
	}
	defer file.Close()

	deps := make(map[string]string)
	scanner := bufio.NewScanner(file)

	inRequireBlock := false
	requireStart := regexp.MustCompile(`^\s*require\s*\(`)
	// blockLine := regexp.MustCompile(`^\s*([^\s]+)\s+([^\s]+)$`)
	singleRequire := regexp.MustCompile(`^\s*require\s+([^\s]+)\s+([^\s]+)$`)

	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())

		// Start of require block
		if requireStart.MatchString(line) {
			inRequireBlock = true
			continue
		}

		// End of require block
		if inRequireBlock {
			if line == ")" {
				inRequireBlock = false
				continue
			}
			l := strings.Split(line, " ")
			if _, ok := deps[l[0]]; ok {
				fmt.Println(l[0], l[1])
			} else {
				if len(l) == 1 {
					continue
				}
				deps[l[0]] = l[1]
			}
		} else {
			if strings.Contains(line, "=>") {
				l := strings.Split(line, "=>")
				l1 := strings.Split(l[1], " ")
				if len(l1) == 3 {
					deps[l1[1]] = l1[2]
				}
			}
			if matches := singleRequire.FindStringSubmatch(line); len(matches) == 3 {
				deps[matches[1]] = matches[2]
			}
		}
	}

	return deps, scanner.Err()
}

// Writes a go.mod file with the provided dependencies
func writeGoMod(path string, deps map[string]string, moduleName string) error {
	file, err := os.Create(path)
	if err != nil {
		return err
	}
	defer file.Close()

	_, err = file.WriteString(fmt.Sprintf("module %s\n\ngo 1.21\n\nrequire (\n", moduleName))
	if err != nil {
		return err
	}

	for mod, ver := range deps {
		_, err = file.WriteString(fmt.Sprintf("\t%s %s\n", mod, ver))
		if err != nil {
			return err
		}
	}

	_, err = file.WriteString(")\n")
	return err
}

func main() {
	if len(os.Args) < 4 {
		fmt.Println("Usage: go run mergegomod.go <goMod1> <goMod2> <outputGoMod>")
		return
	}

	goMod1Path := os.Args[1]
	goMod2Path := os.Args[2]
	outputPath := os.Args[3]

	// Parse go.mod files
	goMod1, err := parseGoMod(goMod1Path)
	if err != nil {
		fmt.Println("Error reading goMod1:", err)
		return
	}

	goMod2, err := parseGoMod(goMod2Path)
	if err != nil {
		fmt.Println("Error reading goMod2:", err)
		return
	}

	// Debug: Print parsed maps
	fmt.Println("---- goMod1 map ----", len(goMod1))
	fmt.Println("---- goMod1 map ----", len(goMod2))
	// for k, v := range goMod2 {
	// 	if val, ok := goMod1[k]; ok {
	// 		fmt.Println(k, v, val)
	// 	}
	// }

	// fmt.Println("---- goMod2 map ----")
	// for mod, ver := range goMod2 {
	// 	fmt.Printf("%s => %s\n", mod, ver)
	// }

	// Merge logic
	merged := make(map[string]string)

	fmt.Printf("\n%-40s %-15s %-15s %-15s\n", "MODULE", "v1", "v2", "USED")
	fmt.Println(strings.Repeat("-", 90))

	count := 0
	for mod, v2 := range goMod2 {
		if v1, found := goMod1[mod]; found {
			merged[mod] = v1
			if v1 != v2 {
				fmt.Printf("%-40s %-15s %-15s\n", mod, v1, v2)
				count += 1
				err := updateGoModVersion("new.mod", mod, v1)
				if err != nil {
					fmt.Println("Error:", err)
				}

				// err = printUpdatedLines("new.mod", mod, v1)
				// if err != nil {
				// 	fmt.Println("Error:", err)
				// }

				err = updateModuleVersionInFile("new.mod", mod, v1)
				if err != nil {
					fmt.Println("Error:", err)
				} else {
					fmt.Println("go.mod updated successfully.")
				}
			}
		} else {
			merged[mod] = v2
		}
	}
	fmt.Println("COUNT: ", count)

	// // Write merged go.mod
	// err = writeGoMod(outputPath, merged, "merged/module")
	// if err != nil {
	// 	fmt.Println("Error writing output go.mod:", err)
	// 	return
	// }

	fmt.Println("\n✅ Merged go.mod written to:", outputPath)
}

func updateGoModVersion(filename, moduleName, newVersion string) error {
	inputFile, err := os.Open(filename)
	if err != nil {
		return fmt.Errorf("failed to open file: %v", err)
	}
	defer inputFile.Close()

	// timestamp := time.Now().Format("20060102_150405")
	outputFilename := fmt.Sprintf("newfilemod.mod")
	outputFile, err := os.Create(outputFilename)
	if err != nil {
		return fmt.Errorf("failed to create output file: %v", err)
	}
	defer outputFile.Close()

	scanner := bufio.NewScanner(inputFile)
	writer := bufio.NewWriter(outputFile)

	for scanner.Scan() {
		line := scanner.Text()
		trimmed := strings.TrimSpace(line)

		// Update lines that mention the module
		if strings.HasPrefix(trimmed, moduleName+" ") || strings.Contains(trimmed, moduleName+" => "+moduleName+" ") {
			// Replace the version part
			parts := strings.Fields(trimmed)
			if len(parts) >= 2 {
				// for both require and replace lines
				if strings.Contains(trimmed, "=>") {
					line = strings.Replace(line, parts[len(parts)-1], "v"+newVersion, 1)
				} else {
					line = strings.Replace(line, parts[1], "v"+newVersion, 1)
				}
			}
		}

		_, err := writer.WriteString(line + "\n")
		if err != nil {
			return fmt.Errorf("failed to write to output file: %v", err)
		}
	}

	if err := scanner.Err(); err != nil {
		return fmt.Errorf("scanner error: %v", err)
	}

	if err := writer.Flush(); err != nil {
		return fmt.Errorf("flush error: %v", err)
	}

	// fmt.Printf("Updated file written to: %s\n", outputFilename)
	return nil
}

func printUpdatedLines(filename, moduleName, newVersion string) error {
	fmt.Println("NEW VERSION", newVersion)
	file, err := os.Open(filename)
	if err != nil {
		return fmt.Errorf("failed to open file: %v", err)
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)

	for scanner.Scan() {
		line := scanner.Text()
		trimmed := strings.TrimSpace(line)

		// Match both require and replace lines
		if strings.HasPrefix(trimmed, moduleName+" ") || strings.Contains(trimmed, moduleName+" => "+moduleName+" ") {
			fields := strings.Fields(trimmed)

			// Handle replace: module => module vX.Y.Z
			if strings.Contains(trimmed, "=>") && len(fields) >= 4 {
				fields[len(fields)-1] = "v" + newVersion
				fmt.Println(strings.Join(fields, " "))
			} else if len(fields) >= 2 {
				// Handle require: module vX.Y.Z
				fields[1] = "v" + newVersion
				fmt.Println(strings.Join(fields, " "))
			} else {
				fmt.Println(line)
			}
		} else {
			// Print line unchanged
			fmt.Println(line)
		}
	}

	if err := scanner.Err(); err != nil {
		return fmt.Errorf("scanner error: %v", err)
	}

	return nil
}

func updateModuleVersionInFile(filename, moduleName, newVersion string) error {
	fmt.Println("Updating version to", newVersion)

	file, err := os.Open(filename)
	if err != nil {
		return fmt.Errorf("failed to open file: %v", err)
	}
	defer file.Close()

	var updatedLines []string
	scanner := bufio.NewScanner(file)

	for scanner.Scan() {
		line := scanner.Text()
		trimmed := strings.TrimSpace(line)

		// Match both require and replace lines
		if strings.HasPrefix(trimmed, moduleName+" ") || strings.Contains(trimmed, moduleName+" => "+moduleName+" ") {
			fields := strings.Fields(trimmed)

			if strings.Contains(trimmed, "=>") && len(fields) >= 4 {
				fields[len(fields)-1] = "" + newVersion
				updatedLines = append(updatedLines, strings.Join(fields, " "))
			} else if len(fields) >= 2 {
				fields[1] = "v" + newVersion
				updatedLines = append(updatedLines, strings.Join(fields, " "))
			} else {
				updatedLines = append(updatedLines, line)
			}
		} else {
			updatedLines = append(updatedLines, line)
		}
	}

	if err := scanner.Err(); err != nil {
		return fmt.Errorf("scanner error: %v", err)
	}

	// Write the updated content back to the file
	output := strings.Join(updatedLines, "\n") + "\n"
	err = os.WriteFile(filename, []byte(output), 0644)
	if err != nil {
		return fmt.Errorf("failed to write updated file: %v", err)
	}

	return nil
}
