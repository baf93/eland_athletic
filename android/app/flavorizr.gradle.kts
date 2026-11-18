import com.android.build.gradle.AppExtension

val android = project.extensions.getByType(AppExtension::class.java)

android.apply {
    flavorDimensions("flavor-type")

    productFlavors {
        create("userApp") {
            dimension = "flavor-type"
            applicationId = "com.eland.athletic"
            resValue(type = "string", name = "app_name", value = "Eland Athletic")
        }
        create("proApp") {
            dimension = "flavor-type"
            applicationId = "com.eland.athletic.pro"
            resValue(type = "string", name = "app_name", value = "Eland Pro")
        }
    }

    buildFeatures.resValues = true
}