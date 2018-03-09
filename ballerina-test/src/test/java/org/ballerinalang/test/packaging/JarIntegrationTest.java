package org.ballerinalang.test.packaging;

import org.testng.Assert;
import org.testng.annotations.AfterClass;
import org.testng.annotations.BeforeClass;
import org.testng.annotations.Test;
import org.wso2.ballerinalang.compiler.packaging.Patten;
import org.wso2.ballerinalang.compiler.packaging.repo.JarRepo;
import org.wso2.ballerinalang.compiler.packaging.resolve.Converter;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;
import java.util.stream.Collectors;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

import static org.wso2.ballerinalang.compiler.packaging.Patten.path;

public class JarIntegrationTest {

    private static final byte[] BAL_CONTENT = "good bal".getBytes(StandardCharsets.UTF_8);
    private Path tempJar;

    @BeforeClass
    public void setup() throws IOException {
        tempJar = Files.createTempFile("bal-unit#test jar-resolve-", ".jar");

        try (ZipOutputStream zs = new ZipOutputStream(Files.newOutputStream(tempJar))) {
            ZipEntry zipEntry = new ZipEntry("very/deep/path#to the/dir.bal/tempFile.bal");
            try {
                zs.putNextEntry(zipEntry);
                zs.write(BAL_CONTENT);
                zs.closeEntry();
            } catch (IOException e) {
                Assert.fail("creating a jar failed", e);
            }
        }
    }

    @Test
    public void balInsideJar() throws IOException {
        Patten balPatten = new Patten(path("very"), Patten.WILDCARD_SOURCE);
        JarRepo repo = new JarRepo(tempJar.toUri());
        Converter<Path> converter = repo.getConverterInstance();
        List<Path> paths = balPatten.convertToPaths(converter)
                                    .collect(Collectors.toList());
        Assert.assertEquals(paths.size(), 1);
        Assert.assertEquals(Files.readAllBytes(paths.get(0)), BAL_CONTENT);
    }

    @AfterClass
    public void teardown() throws IOException {
        Files.delete(tempJar);
    }
}
