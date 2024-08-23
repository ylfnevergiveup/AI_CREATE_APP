//
//  ContentView.swift
//  time-app
//
//  Created by 叶李烽 on 2024/8/23.
//


import SwiftUI
import AVFoundation

struct ContentView: View {
    var body: some View {
        TabView {
            // 倒计时页面
            CountdownView()
                .tabItem {
                    Label("倒计时", systemImage: "hourglass.bottomhalf.fill")
                }
            
            // 计时器页面
            TimerView()
                .tabItem {
                    Label("计时器", systemImage: "stopwatch.fill")
                }
            
            // 番茄钟页面
            PomodoroView()
                .tabItem {
                    Label("番茄钟", systemImage: "clock.fill")
                }
            
            // 我的页面
            ProfileView()
                .tabItem {
                    Label("我的", systemImage: "person.fill")
                }
        }
    }
}

// 倒计时页面
struct CountdownView: View {
    @State private var timerRunning = false
    @State private var minutesInput = "25"
    @State private var secondsInput = "00"
    @State private var timeRemaining = 0
    @State private var timer: Timer? = nil
    @State private var audioPlayer: AVAudioPlayer?

    var body: some View {
        VStack {
            Text("倒计时")
                .font(.headline)
                .padding(.top, 50)

            Text(timeString(time: timeRemaining))
                .font(.system(size: 64, weight: .bold, design: .monospaced))
                .padding(.top, 10)

            Spacer()

            HStack(spacing: 10) {
                TextField("分钟", text: $minutesInput)
                    .keyboardType(.numberPad)
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .frame(width: 60)
                    .background(Color(white: 0.9))
                    .cornerRadius(10)
                
                Text(":")
                    .font(.title)
                
                TextField("秒钟", text: $secondsInput)
                    .keyboardType(.numberPad)
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .frame(width: 60)
                    .background(Color(white: 0.9))
                    .cornerRadius(10)
            }
            .padding(.vertical, 30)

            HStack(spacing: 20) {
                Button(action: {
                    if timerRunning {
                        stopTimer()
                    } else {
                        startTimer()
                    }
                }) {
                    Text(timerRunning ? "暂停" : "开始")
                        .font(.title2)
                        .padding(.vertical, 10) // 调整垂直方向的内边距
                        .padding(.horizontal, 20) // 调整水平方向的内边距
                        .background(timerRunning ? Color.red : Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .frame(width: 120, height: 40)
                }

                Button(action: {
                    resetTimer()
                    stopAlarm()
                }) {
                    Text("重置")
                        .font(.title2)
                        .padding(.vertical, 10) // 调整垂直方向的内边距
                        .padding(.horizontal, 20) // 调整水平方向的内边距
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .frame(width: 120, height: 40)
                }
            }
        }
        .onAppear {
            resetTimer()
        }
    }

    func startTimer() {
        timerRunning = true
        let totalTime = (Int(minutesInput) ?? 0) * 60 + (Int(secondsInput) ?? 0)
        timeRemaining = totalTime
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.stopTimer()
                playAlarm()
            }
        }
    }

    func stopTimer() {
        timerRunning = false
        timer?.invalidate()
        timer = nil
    }

    func resetTimer() {
        stopAlarm()
        timeRemaining = 0
        timerRunning = false
        timer?.invalidate()
        timer = nil
    }

    func timeString(time: Int) -> String {
        let minutes = time / 60
        let seconds = time % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    func playAlarm() {
        if let url = Bundle.main.url(forResource: "alarm", withExtension: "m4a") {
            audioPlayer = try? AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        }
    }

    func stopAlarm() {
        audioPlayer?.stop()
    }
}

// 计时器页面
struct TimerView: View {
    @State private var timerRunning = false
    @State private var timeElapsed = 0
    @State private var timer: Timer? = nil
    @State private var selectedMusic: String = "music1" // 默认音乐
    @State private var audioPlayer: AVAudioPlayer?

    // 音乐选项
    let musicOptions = ["music1", "music2", "music3"]

    var body: some View {
        VStack {
            Text("计时器")
                .font(.headline)
                .padding(.top, 50)

            // 选择背景音乐
            Picker("选择背景音乐", selection: $selectedMusic) {
                ForEach(musicOptions, id: \.self) { music in
                    Text(music)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .padding()

            Text(timeString(time: timeElapsed))
                .font(.system(size: 64, weight: .bold, design: .monospaced))
                .padding(.top, 10)

            Spacer()

            HStack(spacing: 20) {
                Button(action: {
                    if timerRunning {
                        stopTimer()
                        stopMusic() // 停止音乐
                    } else {
                        startTimer()
                        playSelectedMusic() // 播放音乐
                    }
                }) {
                    Text(timerRunning ? "暂停" : "开始")
                        .font(.title2)
                        .padding(.vertical, 10) // 调整垂直方向的内边距
                        .padding(.horizontal, 20) // 调整水平方向的内边距
                        .background(timerRunning ? Color.red : Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .frame(width: 120, height: 40)
                }

                Button(action: {
                    resetTimer()
                    stopMusic() // 停止音乐
                }) {
                    Text("重置")
                        .font(.title2)
                        .padding(.vertical, 10) // 调整垂直方向的内边距
                        .padding(.horizontal, 20) // 调整水平方向的内边距
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .frame(width: 120, height: 40)
                }
            }
        }
        .onAppear {
            resetTimer() // 确保计时器重置
        }
        .onChange(of: selectedMusic) { newValue in
            if timerRunning {
                playSelectedMusic() // 当选择的音乐变化时播放新音乐
            }
        }
    }

    func startTimer() {
        timerRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.timeElapsed += 1
        }
    }

    func stopTimer() {
        timerRunning = false
        timer?.invalidate()
        timer = nil
    }

    func resetTimer() {
        stopTimer()
        timeElapsed = 0
    }

    func playSelectedMusic() {
        stopMusic()
        let musicFile = "\(selectedMusic).m4a"
        if let url = Bundle.main.url(forResource: musicFile, withExtension: nil, subdirectory: "music") {
            audioPlayer = try? AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1 // 无限循环播放
            audioPlayer?.play()
        }
    }
    
    func stopMusic() {
        audioPlayer?.stop()
        audioPlayer = nil
    }

    func timeString(time: Int) -> String {
        let minutes = time / 60
        let seconds = time % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// 番茄钟页面
import SwiftUI
import AVFoundation

struct PomodoroView: View {
    @State private var timerRunning = false
    @State private var timeRemaining = 0
    @State private var selectedMinutes = 25 // 默认25分钟
    @State private var selectedSeconds = 0  // 默认0秒
    @State private var timer: Timer? = nil
    @State private var audioPlayer: AVAudioPlayer?

    var body: some View {
        VStack {
            Text("番茄钟")
                .font(.headline)
                .padding(.top, 50)
            
            HStack {
                Picker("分钟", selection: $selectedMinutes) {
                    ForEach(0..<121, id: \.self) { minute in
                        Text("\(minute) 分钟")
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(maxWidth: .infinity, maxHeight: 150)
                .clipped()
                
                Picker("秒钟", selection: $selectedSeconds) {
                    ForEach(0..<60, id: \.self) { second in
                        Text("\(second) 秒")
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(maxWidth: .infinity, maxHeight: 150)
                .clipped()
            }

            Text(timeString(time: timeRemaining))
                .font(.system(size: 64, weight: .bold, design: .monospaced))
                .padding(.top, 10)

            Spacer()

            Button(action: {
                if timerRunning {
                    stopTimer()
                } else {
                    startTimer()
                }
            }) {
                Text(timerRunning ? "暂停" : "开始")
                    .font(.title2)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
                    .background(timerRunning ? Color.red : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .frame(width: 120, height: 40)
            }
        }
        .onAppear {
            setupAudioSession()
            NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: .main) { _ in
                self.appMovedToBackground()
            }
            NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { _ in
                self.appMovedToForeground()
            }
        }
    }

    func startTimer() {
        timeRemaining = selectedMinutes * 60 + selectedSeconds
        timerRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.stopTimer()
            }
        }
    }

    func stopTimer() {
        timerRunning = false
        timer?.invalidate()
        timer = nil
    }

    func resetTimer() {
        timeRemaining = selectedMinutes * 60 + selectedSeconds
        timerRunning = false
        timer?.invalidate()
        timer = nil
    }

    func timeString(time: Int) -> String {
        let minutes = time / 60
        let seconds = time % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session")
        }
    }

    func appMovedToBackground() {
        if timerRunning {
            playAlarm()
        }
    }

    func appMovedToForeground() {
        stopAlarm()
    }

    func playAlarm() {
        if let url = Bundle.main.url(forResource: "alarm", withExtension: "m4a") {
            audioPlayer = try? AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1 // 无限循环播放
            audioPlayer?.play()
        }
    }

    func stopAlarm() {
        audioPlayer?.stop()
        audioPlayer = nil
    }
}

struct PomodoroView_Previews: PreviewProvider {
    static var previews: some View {
        PomodoroView()
    }
}

// 我的页面
struct ProfileView: View {
    @State private var nickname = "昵称"
    @State private var account = "账号"
    @State private var phoneNumber = ""
    @State private var isEditing = false
    @State private var isRegistered = false // 是否已经注册
    @State private var showImagePicker = false
    @State private var profileImage: UIImage? = UIImage(systemName: "person.circle")

    var body: some View {
        VStack {
            Spacer()

            if isRegistered {
                // 已注册时显示用户信息
                Button(action: {
                    self.showImagePicker = true
                }) {
                    if let image = profileImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.gray)
                    }
                }
                .padding()

                VStack(alignment: .leading) {
                    Text("昵称: \(nickname)")
                        .font(.title2)
                        .padding(.bottom, 5)
                    Text("账号: \(account)")
                        .font(.title2)
                        .padding(.bottom, 20)
                }

                Spacer()

                // 编辑个人信息按钮
                Button(action: {
                    self.isEditing.toggle()
                }) {
                    Text("编辑个人信息")
                        .font(.title2)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
                .sheet(isPresented: $isEditing) {
                    EditProfileView(nickname: $nickname, account: $account)
                }
            } else {
                // 未注册时显示手机号码注册
                VStack {
                    TextField("输入手机号码", text: $phoneNumber)
                        .keyboardType(.phonePad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()

                    Button(action: {
                        registerWithPhoneNumber()
                    }) {
                        Text("使用手机号码注册")
                            .font(.title2)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()
                }
            }
            
            Spacer()
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: self.$profileImage)
        }
    }

    func registerWithPhoneNumber() {
        // 这里实现通过手机号码注册的逻辑，比如通过短信验证
        // 如果注册成功，更新状态
        isRegistered = true
        // 更新账号信息，例如使用电话号码作为账号
        account = phoneNumber
    }
}
struct EditProfileView: View {
    @Binding var nickname: String
    @Binding var account: String
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            TextField("昵称", text: $nickname)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("账号", text: $account)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Spacer()

            Button(action: {
                saveChanges()
            }) {
                Text("保存")
                    .font(.title2)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
        .padding()
    }

    func saveChanges() {
        // 保存用户信息的逻辑
        // 这里可以添加与后端交互的逻辑，保存数据

        // 返回上一个视图
        presentationMode.wrappedValue.dismiss()
    }
}
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }

            picker.dismiss(animated: true)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // 不需要在这里做额外的更新
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
