interface Props {
    value: number;
    label?: string;
}

export const Bar = ({
    value,
    label,
}: Props) => {
    const amount = Math.max(0, Math.min(100, value));
    return (
        <article className="relative flex items-center flex-1 gap-4 transition-opacity duration-500">
            {(label === "Health" || label === "Armor") && (
                <span
                    className={`flex items-center justify-center w-5 h-5 text-sm ${label === "Health" ? "text-white" : "text-[#38b6ff]"}`}
                >
                    {label === "Health" ? <i className="fas fa-heart"></i> : <i className="fas fa-shield"></i>}
                </span>
            )}
            <div
                className="relative flex-1 h-2 overflow-hidden"
                style={{
                    background: "linear-gradient(135deg, rgba(255, 255, 255, 0.08) 0%, rgba(255, 255, 255, 0.12) 100%)",
                    border: "1px solid rgba(255, 255, 255, 0.15)",
                }}
            >
                <div
                    className="absolute top-0 left-0 h-full"
                    style={{
                        width: amount + "%",
                        background: label === "Health" ? "#ffffff" : "#38b6ff",
                        transition: "width 0.2s",
                    }}
                ></div>
            </div>
        </article>
    );
};
