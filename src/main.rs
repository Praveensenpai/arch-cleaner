use colored::*;
use inquire::MultiSelect;
use std::fs;
use std::path::{Path, PathBuf};
use std::process::Command;
use walkdir::WalkDir;

fn format_bytes(bytes: u64) -> String {
    const KB: u64 = 1024;
    const MB: u64 = KB * 1024;
    const GB: u64 = MB * 1024;

    if bytes >= GB {
        format!("{:.2} GB", bytes as f64 / GB as f64)
    } else if bytes >= MB {
        format!("{:.1} MB", bytes as f64 / MB as f64)
    } else if bytes >= KB {
        format!("{:.1} KB", bytes as f64 / KB as f64)
    } else {
        format!("{} B", bytes)
    }
}

fn get_dir_size(path: &Path) -> u64 {
    if !path.exists() {
        return 0;
    }
    WalkDir::new(path)
        .into_iter()
        .filter_map(|e| e.ok())
        .filter_map(|e| e.metadata().ok())
        .filter(|m| m.is_file())
        .map(|m| m.len())
        .sum()
}

fn get_journal_usage() -> String {
    let output = Command::new("journalctl")
        .arg("--disk-usage")
        .output();

    if let Ok(out) = output {
        let text = String::from_utf8_lossy(&out.stdout);
        // Typical output: "Archived and active journals take up 1.2G in the file system."
        if let Some(pos) = text.find("take up ") {
            let rest = &text[pos + 8..];
            if let Some(end) = rest.find(" in the file system") {
                return rest[..end].trim().to_string();
            }
        }
        text.trim().to_string()
    } else {
        "0B".to_string()
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum CleanupTask {
    PacmanYayCache,
    SystemdJournal,
    UserTrash,
    ThumbnailCache,
}

impl std::fmt::Display for CleanupTask {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            CleanupTask::PacmanYayCache => write!(f, "Pacman & Yay Cache"),
            CleanupTask::SystemdJournal => write!(f, "Systemd Journal Logs (vacuum to 50MB)"),
            CleanupTask::UserTrash => write!(f, "User Trash"),
            CleanupTask::ThumbnailCache => write!(f, "Thumbnail Cache"),
        }
    }
}

fn main() {
    println!("{}", "=========================================".magenta().bold());
    println!("{}", "   🌸 Interactive System Cleanup Utility ✨".cyan().bold());
    println!("{}\n", "=========================================".magenta().bold());

    let home = std::env::var("HOME").unwrap_or_else(|_| "/home/paisen".to_string());
    let home_path = PathBuf::from(&home);

    let pacman_dir = Path::new("/var/cache/pacman/pkg");
    let yay_dir = home_path.join(".cache/yay");
    let trash_dir = home_path.join(".local/share/Trash");
    let thumb_dir = home_path.join(".cache/thumbnails");

    println!("{}", "🔍 Scanning disk usage...".yellow());

    // Calculate sizes concurrently using rayon join
    let ((pacman_size, yay_size), (trash_size, (thumb_size, journal_usage))) = rayon::join(
        || rayon::join(|| get_dir_size(pacman_dir), || get_dir_size(&yay_dir)),
        || rayon::join(
            || get_dir_size(&trash_dir),
            || rayon::join(|| get_dir_size(&thumb_dir), get_journal_usage),
        ),
    );

    let opt1 = format!("1. Pacman & Yay Cache ({}/pacman, {}/yay)", format_bytes(pacman_size), format_bytes(yay_size));
    let opt2 = format!("2. Systemd Journal Logs ({})", journal_usage);
    let opt3 = format!("3. Empty User Trash ({})", format_bytes(trash_size));
    let opt4 = format!("4. Thumbnail Cache ({})", format_bytes(thumb_size));

    let options = vec![
        (&opt1, CleanupTask::PacmanYayCache),
        (&opt2, CleanupTask::SystemdJournal),
        (&opt3, CleanupTask::UserTrash),
        (&opt4, CleanupTask::ThumbnailCache),
    ];

    let defaults = vec![0, 1, 2]; // Options 1, 2, 3 selected by default

    let selected = MultiSelect::new("Select items to clean:", options.iter().map(|o| o.0).collect())
        .with_default(&defaults)
        .prompt();

    let choices = match selected {
        Ok(c) => c,
        Err(_) => {
            println!("{}", "Cleanup cancelled.".yellow());
            return;
        }
    };

    if choices.is_empty() {
        println!("{}", "No items selected. Exiting.".yellow());
        return;
    }

    println!("\n{}", "▶ Starting selected cleanup...".cyan().bold());
    println!("-----------------------------------------");

    for choice in choices {
        if choice == &opt1 {
            println!("🧹 Cleaning Pacman & Yay package caches...");
            let _ = Command::new("sudo")
                .args(["rm", "-rf", "/var/cache/pacman/pkg/*"])
                .status();
            let _ = fs::remove_dir_all(&yay_dir);
            let _ = fs::create_dir_all(&yay_dir);
        } else if choice == &opt2 {
            println!("📜 Vacuuming systemd journal logs (50MB cap)...");
            let _ = Command::new("sudo")
                .args(["journalctl", "--vacuum-size=50M"])
                .status();
        } else if choice == &opt3 {
            println!("🗑️ Emptying user trash...");
            let trash_files = trash_dir.join("files");
            let trash_info = trash_dir.join("info");
            let _ = fs::remove_dir_all(&trash_files);
            let _ = fs::remove_dir_all(&trash_info);
            let _ = fs::create_dir_all(&trash_files);
            let _ = fs::create_dir_all(&trash_info);
        } else if choice == &opt4 {
            println!("🖼️ Clearing thumbnail cache...");
            let _ = fs::remove_dir_all(&thumb_dir);
            let _ = fs::create_dir_all(&thumb_dir);
        }
    }

    println!("-----------------------------------------");
    println!("{}", "✔ Selected cleanup completed successfully! ✨".green().bold());
}
